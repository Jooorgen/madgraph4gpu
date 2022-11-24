//==========================================================================
// This file has been automatically generated for SYCL standalone by
// MadGraph5_aMC@NLO v. 3.4.0_lo_vect, 2022-05-06
// By the MadGraph5_aMC@NLO Development Team
// Visit launchpad.net/madgraph5 and amcatnlo.web.cern.ch
//==========================================================================

#include <algorithm>
#include <array>
#include <cstring>
#include <memory>

#include "mgOnGpuConfig.h"
#include "mgOnGpuTypes.h"
#include "mgOnGpuVectors.h"

#include "CPPProcess.h"
#include "HelAmps_sm.h"

//==========================================================================
// Class member functions for calculating the matrix elements for
// Process: g g > t t~ WEIGHTED<=2 @1

namespace Proc
{
  static constexpr int np4 = mgOnGpu::np4; // dimensions of 4-momenta (E,px,py,pz)
  static constexpr int npar = mgOnGpu::npar; // #particles in total (external = initial + final): e.g. 4 for e+ e- -> mu+ mu-
  static constexpr int ncomb = mgOnGpu::ncomb; // #helicity combinations: e.g. 16 for e+ e- -> mu+ mu- (2**4 = fermion spin up/down ** npar)

  static constexpr int nwf = mgOnGpu::nwf; // #wavefunctions = #external (npar) + #internal: e.g. 5 for e+ e- -> mu+ mu- (1 internal is gamma or Z)
  static constexpr int nw6 = mgOnGpu::nw6; // dimensions of each wavefunction (HELAS KEK 91-11): e.g. 6 for e+ e- -> mu+ mu- (fermions and vectors)
  static constexpr int neppM = mgOnGpu::neppM; // AOSOA layout: constant at compile-time

  //--------------------------------------------------------------------------

  // Evaluate |M|^2 for each subprocess
  // NB: calculate_wavefunctions ADDS |M|^2 for a given ihel to the running sum of |M|^2 over helicities for the given event(s)
  SYCL_EXTERNAL
  INLINE
  fptype calculate_wavefunctions( const fptype_sv* __restrict__ allmomenta, // input: momenta as AOSOA[npagM][npar][4][neppM] with nevt=npagM*neppM
                                  #ifdef MGONGPU_SUPPORTS_MULTICHANNEL
                                      fptype* __restrict__ allNumerators,   // output: multichannel numerators, running_sum_over_helicities
                                      fptype* __restrict__ allDenominators, // output: multichannel denominators, running_sum_over_helicities
                                      const unsigned int channelId,         // input: multichannel channel id (1 to #diagrams); 0 to disable channel enhancement
                                  #endif
                                  const short*  __restrict__ cHel,
                                  const cxtype* __restrict__ COUPs,
                                  const fptype* __restrict__ cIPD
                                )
  //ALWAYS_INLINE // attributes are not permitted in a function definition
  {
    using namespace MG5_sm;
    mgDebug( 0, __FUNCTION__ );
    fptype allMEs = 0;
    //const cxtype* COUPs = reinterpret_cast<const cxtype*>(cIPC);


    // The number of colors
    constexpr int ncolor = 2;

    // Local TEMPORARY variables for a subset of Feynman diagrams in the given SYCL event (ievt)
    // [NB these variables are reused several times (and re-initialised each time) within the same event or event page]
    cxtype_sv w_sv[nwf][nw6]; // particle wavefunctions within Feynman diagrams (nw6 is often 6, the dimension of spin 1/2 or spin 1 particles)
    cxtype_sv amp_sv[1]; // invariant amplitude for one given Feynman diagram

    // Local variables for the given SYCL event (ievt)
    cxtype_sv jamp_sv[ncolor] = {}; // sum of the invariant amplitudes for all Feynman diagrams in the event or event page

    // === Calculate wavefunctions and amplitudes for all diagrams in all processes - Loop over nevt events ===

    {
      // Reset color flows (reset jamp_sv) at the beginning of a new event or event page
      for( int i=0; i<ncolor; i++ ){ jamp_sv[i] = cxzero_sv(); }

      // *** DIAGRAM 1 OF 3 ***

      // Wavefunction(s) for diagram number 1
      vxxxxx( allmomenta + 0 * np4 * neppM, 0., cHel[0], -1, w_sv[0]);

      vxxxxx( allmomenta + 1 * np4 * neppM, 0., cHel[1], -1, w_sv[1]);

      oxxxxx( allmomenta + 2 * np4 * neppM, cIPD[0], cHel[2], +1, w_sv[2]);

      ixxxxx( allmomenta + 3 * np4 * neppM, cIPD[0], cHel[3], -1, w_sv[3]);

      VVV1P0_1( w_sv[0], w_sv[1], COUPs[0], 0., 0., w_sv[4] );

      // Amplitude(s) for diagram number 1
      FFV1_0( w_sv[3], w_sv[2], w_sv[4], COUPs[1], &amp_sv[0] );
#ifdef MGONGPU_SUPPORTS_MULTICHANNEL
      // Here the code base generated with multichannel support updates numerators_sv and denominators_sv (#473)
#endif
      jamp_sv[0] += cxtype( 0, 1 ) * amp_sv[0];
      jamp_sv[1] -= cxtype( 0, 1 ) * amp_sv[0];

      // *** DIAGRAM 2 OF 3 ***

      // Wavefunction(s) for diagram number 2
      FFV1_1( w_sv[2], w_sv[0], COUPs[1], cIPD[0], cIPD[1], w_sv[4] );

      // Amplitude(s) for diagram number 2
      FFV1_0( w_sv[3], w_sv[4], w_sv[1], COUPs[1], &amp_sv[0] );
#ifdef MGONGPU_SUPPORTS_MULTICHANNEL
      // Here the code base generated with multichannel support updates numerators_sv and denominators_sv (#473)
#endif
      jamp_sv[0] -= amp_sv[0];

      // *** DIAGRAM 3 OF 3 ***

      // Wavefunction(s) for diagram number 3
      FFV1_2( w_sv[3], w_sv[0], COUPs[1], cIPD[0], cIPD[1], w_sv[4] );

      // Amplitude(s) for diagram number 3
      FFV1_0( w_sv[4], w_sv[2], w_sv[1], COUPs[1], &amp_sv[0] );
#ifdef MGONGPU_SUPPORTS_MULTICHANNEL
      // Here the code base generated with multichannel support updates numerators_sv and denominators_sv (#473)
#endif
      jamp_sv[1] -= amp_sv[0];

      // *** COLOR ALGEBRA BELOW ***
      // (This method used to be called CPPProcess::matrix_1_gg_ttx()?)

      // The color matrix (initialize all array elements, with ncolor=1)
      // [NB do keep 'static' for these constexpr arrays, see issue #283]
      static constexpr fptype denom[ncolor] = {3, 3};
      static constexpr fptype cf[ncolor][ncolor] = {
      {16, -2},
      {-2, 16}};

      // Sum and square the color flows to get the matrix element
      // (compute |M|^2 by squaring |M|, taking into account colours)
      fptype_sv deltaMEs = { 0 }; // all zeros
      for( int icol = 0; icol < ncolor; icol++ )
      {
        cxtype_sv ztemp_sv = cxzero_sv();
        for( int jcol = 0; jcol < ncolor; jcol++ )
          ztemp_sv += cf[icol][jcol] * jamp_sv[jcol];
        // OLD implementation: why is this not slower? maybe compiler does not compute imaginary part of "ztemp_sv*cxconj(jamp_sv[icol])"?
        //deltaMEs += cxreal( ztemp_sv * cxconj( jamp_sv[icol] ) ) / denom[icol];
        // NEW implementation: keep this even if (surprisingly) it is not faster! it is clearer and easier for tensor core offload anyway...
        // Rewrite the quadratic form (A-iB)(M)(A+iB) as AMA - iBMA + iBMA + BMB = AMA + BMB!
        deltaMEs += ( cxreal( ztemp_sv ) * cxreal( jamp_sv[icol] ) + cximag( ztemp_sv ) * cximag( jamp_sv[icol] ) ) / denom[icol];
      }

      // *** STORE THE RESULTS ***

      // Store the leading color flows for choice of color
      // (NB: jamp2_sv must be an array of fptype_sv)
      // for( int icol = 0; icol < ncolor; icol++ )
      // jamp2_sv[0][icol] += cxreal( jamp_sv[icol]*cxconj( jamp_sv[icol] ) );

      // NB: calculate_wavefunctions ADDS |M|^2 for a given ihel to the running sum of |M|^2 over helicities for the given event(s)
      // FIXME: assume process.nprocesses == 1 for the moment (eventually: need a loop over processes here?)
      allMEs += deltaMEs;
    }
    mgDebug( 1, __FUNCTION__ );
    return allMEs;
  }

  //--------------------------------------------------------------------------

  CPPProcess::CPPProcess( int numiterations,
                          int ngpublocks,
                          int ngputhreads,
                          bool verbose,
                          bool debug )
    : m_numiterations( numiterations )
    , m_ngpublocks( ngpublocks )
    , m_ngputhreads( ngputhreads )
    , m_verbose( verbose )
    , m_debug( debug )
#ifndef MGONGPU_HARDCODE_PARAM
    , m_pars( 0 )
    , m_masses()
#endif
  {
  }

  //--------------------------------------------------------------------------

  CPPProcess::~CPPProcess() {}

  //--------------------------------------------------------------------------

  // Initialize process (with parameters read from user cards)
  void CPPProcess::initProc( const std::string& param_card_name )
  {
#ifndef MGONGPU_HARDCODE_PARAM
    // Instantiate the model class and set parameters that stay fixed during run
    m_pars = Parameters_sm::getInstance();
    SLHAReader slha( param_card_name, m_verbose );
    m_pars->setIndependentParameters( slha );
    m_pars->setIndependentCouplings();
    //m_pars->setDependentParameters();
    //m_pars->setDependentCouplings();
    if ( m_verbose )
    {
      m_pars->printIndependentParameters();
      m_pars->printIndependentCouplings();
      //m_pars->printDependentParameters();
      //m_pars->printDependentCouplings();
    }
    // Set external particle masses for this matrix element
    m_masses.push_back( m_pars->ZERO );
    m_masses.push_back( m_pars->ZERO );
    m_masses.push_back( m_pars->mdl_MT );
    m_masses.push_back( m_pars->mdl_MT );
    // Read physics parameters like masses and couplings from user configuration files (static: initialize once)
    //m_tIPC[...] = ... ; // nicoup=0
    m_tIPD[0] = (fptype)m_pars->mdl_MT;
    m_tIPD[1] = (fptype)m_pars->mdl_WT;

#endif
  }

  //--------------------------------------------------------------------------
#ifndef MGONGPU_HARDCODE_PARAM
  // Define pointer accessors
  cxtype* CPPProcess::get_tIPC_ptr() {return m_tIPC;}
  const cxtype* CPPProcess::get_tIPC_ptr() const {return m_tIPC;}

  fptype* CPPProcess::get_tIPD_ptr() {return m_tIPD;}
  const fptype* CPPProcess::get_tIPD_ptr() const {return m_tIPD;}
#endif

  //--------------------------------------------------------------------------

  SYCL_EXTERNAL
  void sigmaKin_getGoodHel( const fptype* __restrict__ allmomenta, // input: momenta[nevt*npar*4]
                            bool* isGoodHel,                       // output: isGoodHel[ncomb] - device array
                            const short* __restrict__ cHel,
                            const cxtype* __restrict__ cIPC,
                            const fptype* __restrict__ cIPD
                            )
  {
    // FIXME: assume process.nprocesses == 1 for the moment (eventually: need a loop over processes here?)
    fptype allMEsLast = 0;
    fptype allMEs = 0;
    for ( int ihel = 0; ihel < ncomb; ihel++ )
    {
      // NB: calculate_wavefunctions ADDS |M|^2 for a given ihel to the running sum of |M|^2 over helicities for the given event(s)
#ifdef MGONGPU_SUPPORTS_MULTICHANNEL
      constexpr unsigned int channelId = 0; // disable single-diagram channel enhancement
      fptype allNumerators = 0;
      fptype allDenominators = 0;
      allMEs += calculate_wavefunctions( allmomenta, &allNumerators, &allDenominators, channelId, cHel + ihel*npar, cIPC, cIPD );
#else
      allMEs += calculate_wavefunctions( allmomenta, cHel + ihel*npar, cIPC, cIPD );
#endif
      if ( allMEs != allMEsLast )
      {
        //if ( !isGoodHel[ihel] ) std::cout << "sigmaKin_getGoodHel ihel=" << ihel << " TRUE" << std::endl;
        isGoodHel[ihel] = true;
      }
      allMEsLast = allMEs; // running sum up to helicity ihel for event ievt
    }
  }

  //--------------------------------------------------------------------------

  int sigmaKin_setGoodHel( const bool* isGoodHel, int* goodHel ) // input: isGoodHel[ncomb] - host array
  {
    int nGoodHel = 0; // FIXME: assume process.nprocesses == 1 for the moment (eventually nGoodHel[nprocesses]?)
    for ( int ihel = 0; ihel < ncomb; ihel++ )
    {
      //std::cout << "sigmaKin_setGoodHel ihel=" << ihel << ( isGoodHel[ihel] ? " true" : " false" ) << std::endl;
      if ( isGoodHel[ihel] )
      {
        //goodHel[nGoodHel[0]] = ihel; // FIXME: assume process.nprocesses == 1 for the moment
        //nGoodHel[0]++; // FIXME: assume process.nprocesses == 1 for the moment
        goodHel[nGoodHel] = ihel;
        nGoodHel++;
      }
    }
    return nGoodHel;
  }

  //--------------------------------------------------------------------------
  // Evaluate |M|^2, part independent of incoming flavour
  // FIXME: assume process.nprocesses == 1 (eventually: allMEs[nevt] -> allMEs[nevt*nprocesses]?)

  SYCL_EXTERNAL
  fptype sigmaKin( const fptype* __restrict__ allmomenta, // input: momenta[nevt*npar*4]
#ifdef MGONGPU_SUPPORTS_MULTICHANNEL
                   const unsigned int channelId,          // input: multichannel channel id (1 to #diagrams); 0 to disable channel enhancement
#endif
                   const short* __restrict__ cHel,
                   const cxtype* __restrict__ cIPC,
                   const fptype* __restrict__ cIPD,
                   const int* __restrict__ cNGoodHel,
                   const int* __restrict__ cGoodHel
                 )
  {
    mgDebugInitialise();

    // Denominators: spins, colors and identical particles
    constexpr int denominators = 256; // FIXME: assume process.nprocesses == 1 for the moment (eventually denominators[nprocesses]?)

    // Set the parameters which change event by event
    // Need to discuss this with Stefan
    //m_pars->setDependentParameters();
    //m_pars->setDependentCouplings();

    // Start sigmaKin_lines
    // PART 0 - INITIALISATION (before calculate_wavefunctions)
    // Reset the "matrix elements" - running sums of |M|^2 over helicities for the given event
    // FIXME: assume process.nprocesses == 1 for the moment (eventually: need a loop over processes here?)
    fptype allMEs = 0;
#ifdef MGONGPU_SUPPORTS_MULTICHANNEL
    fptype allNumerators = 0;
    fptype allDenominators = 0;
#endif

    // PART 1 - HELICITY LOOP: CALCULATE WAVEFUNCTIONS
    // (in both CUDA and C++, using precomputed good helicities)
    // FIXME: assume process.nprocesses == 1 for the moment (eventually: need a loop over processes here?)
    for ( int ighel = 0; ighel < cNGoodHel[0]; ighel++ )
    {
      const int ihel = cGoodHel[ighel];
#ifdef MGONGPU_SUPPORTS_MULTICHANNEL
      allMEs += calculate_wavefunctions( allmomenta, &allNumerators, &allDenominators, channelId, cHel + ihel*npar, cIPC, cIPD );
#else
      allMEs += calculate_wavefunctions( allmomenta, cHel + ihel*npar, cIPC, cIPD );
#endif
    }

    // PART 2 - FINALISATION (after calculate_wavefunctions)
    // Get the final |M|^2 as an average over helicities/colors of the running sum of |M|^2 over helicities for the given event
    // [NB 'sum over final spins, average over initial spins', eg see
    // https://www.uzh.ch/cmsssl/physik/dam/jcr:2e24b7b1-f4d7-4160-817e-47b13dbf1d7c/Handout_4_2016-UZH.pdf]
    // FIXME: assume process.nprocesses == 1 for the moment (eventually: need a loop over processes here?)
    mgDebugFinalise();
#ifdef MGONGPU_SUPPORTS_MULTICHANNEL
    if( channelId > 0 ) allMEs *= allNumerators / allDenominators; // FIXME (#343): assume nprocesses == 1
#endif
    return allMEs / denominators;
  }

  //--------------------------------------------------------------------------

} // end namespace

//==========================================================================

