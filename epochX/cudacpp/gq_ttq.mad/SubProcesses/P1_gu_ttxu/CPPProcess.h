//==========================================================================
// This file has been automatically generated for CUDA/C++ standalone by
// MadGraph5_aMC@NLO v. 3.5.0_lo_vect, 2023-01-26
// By the MadGraph5_aMC@NLO Development Team
// Visit launchpad.net/madgraph5 and amcatnlo.web.cern.ch
//==========================================================================

#ifndef MG5_Sigma_sm_gu_ttxu_H
#define MG5_Sigma_sm_gu_ttxu_H 1

#include "mgOnGpuConfig.h"

#include "mgOnGpuVectors.h"

#include "Parameters_sm.h"

#include <vector>

//--------------------------------------------------------------------------

#ifdef __CUDACC__
namespace mg5amcGpu
#else
namespace mg5amcCpu
#endif
{
  //==========================================================================
  // A class for calculating the matrix elements for
  // Process: g u > t t~ u WEIGHTED<=3 @1
  // Process: g c > t t~ c WEIGHTED<=3 @1
  // Process: g d > t t~ d WEIGHTED<=3 @1
  // Process: g s > t t~ s WEIGHTED<=3 @1
  //--------------------------------------------------------------------------

  class CPPProcess
  {
  public: /* clang-format off */

    // Constructor (from command line arguments)
    CPPProcess( bool verbose = false, bool debug = false );

    // Destructor
    ~CPPProcess();

    // Initialize process (read model parameters from file)
    virtual void initProc( const std::string& param_card_name );

    // Retrieve the compiler that was used to build this module
    static const std::string getCompiler();

    // Other methods of this instance (???)
    //const std::vector<fptype>& getMasses() const { return m_masses; }
    //virtual int code() const{ return 1; }
    //void setInitial( int inid1, int inid2 ){ id1 = inid1; id2 = inid2; }
    //int getDim() const { return dim; }
    //int getNIOParticles() const { return nexternal; } // nexternal was nioparticles

    // Accessors (unused so far: add four of them only to fix a clang build warning)
    //bool verbose() const { return m_verbose; }
    bool debug() const { return m_debug; }

  public: /* clang-format on */

    // Hardcoded parameters for this process (constant class variables)
    // [NB: this class assumes nprocesses==1 i.e. a single DSIG1 and no DSIG2 in Fortran (#272 and #343)]
    //static const int ninitial = mgOnGpu::npari;
    //static const int nexternal = 5; // mgOnGpu::npar (nexternal was nioparticles)
    //static const int nwavefuncs = 6; // mgOnGpu::nwf
    //static const int namplitudes = 5;
    //static const int ncomb = 32; // mgOnGpu::ncomb

  private:

    // Command line arguments (constructor)
    bool m_verbose;
    bool m_debug;

    // Physics model parameters to be read from file (initProc function)
#ifndef MGONGPU_HARDCODE_PARAM
    Parameters_sm* m_pars;
#endif
    std::vector<fptype> m_masses; // external particle masses

    // Other variables of this instance (???)
    //int id1, id2; // initial particle ids
    //cxtype** amp; // ???
  };

  //--------------------------------------------------------------------------

#ifdef __CUDACC__
  __global__ void
  computeDependentCouplings( const fptype* allgs,    // input: Gs[nevt]
                             fptype* allcouplings ); // output: couplings[nevt*ndcoup*2]
#else
  __global__ void
  computeDependentCouplings( const fptype* allgs,  // input: Gs[nevt]
                             fptype* allcouplings, // output: couplings[nevt*ndcoup*2]
                             const int nevt );     // input: #events (for cuda: nevt == ndim == gpublocks*gputhreads)
#endif

  //--------------------------------------------------------------------------

#ifdef __CUDACC__ /* clang-format off */
  __global__ void
  sigmaKin_getGoodHel( const fptype* allmomenta,   // input: momenta[nevt*npar*4]
                       const fptype* allcouplings, // input: couplings[nevt*ndcoup*2]
                       fptype* allMEs,             // output: allMEs[nevt], |M|^2 final_avg_over_helicities
#ifdef MGONGPU_SUPPORTS_MULTICHANNEL
                       fptype* allNumerators,      // output: multichannel numerators[nevt], running_sum_over_helicities
                       fptype* allDenominators,    // output: multichannel denominators[nevt], running_sum_over_helicities
#endif
                       bool* isGoodHel );          // output: isGoodHel[ncomb] - device array (CUDA implementation)
#else
  __global__ void
  sigmaKin_getGoodHel( const fptype* allmomenta,   // input: momenta[nevt*npar*4]
                       const fptype* allcouplings, // input: couplings[nevt*ndcoup*2]
                       fptype* allMEs,             // output: allMEs[nevt], |M|^2 final_avg_over_helicities
#ifdef MGONGPU_SUPPORTS_MULTICHANNEL
                       fptype* allNumerators,      // output: multichannel numerators[nevt], running_sum_over_helicities
                       fptype* allDenominators,    // output: multichannel denominators[nevt], running_sum_over_helicities
#endif
                       bool* isGoodHel,            // output: isGoodHel[ncomb] - host array (C++ implementation)
                       const int nevt );           // input: #events (for cuda: nevt == ndim == gpublocks*gputhreads)
#endif /* clang-format on */

  //--------------------------------------------------------------------------

  int                                           // output: nGoodHel (the number of good helicity combinations out of ncomb)
  sigmaKin_setGoodHel( const bool* isGoodHel ); // input: isGoodHel[ncomb] - host array

  //--------------------------------------------------------------------------

#ifdef __CUDACC__ /* clang-format off */
  __global__ void
  sigmaKin( const fptype* allmomenta,      // input: momenta[nevt*npar*4]
            const fptype* allcouplings,    // input: couplings[nevt*ndcoup*2]
            const fptype* allrndhel,       // input: random numbers[nevt] for helicity selection
            const fptype* allrndcol,       // input: random numbers[nevt] for color selection
            fptype* allMEs,                // output: allMEs[nevt], |M|^2 final_avg_over_helicities
#ifdef MGONGPU_SUPPORTS_MULTICHANNEL
            const unsigned int channelId,  // input: multichannel channel id (1 to #diagrams); 0 to disable channel enhancement
            fptype* allNumerators,         // output: multichannel numerators[nevt], running_sum_over_helicities
            fptype* allDenominators,       // output: multichannel denominators[nevt], running_sum_over_helicities
#endif
            int* allselhel,                // output: helicity selection[nevt]
            int* allselcol                 // output: helicity selection[nevt]
            );
#else
  __global__ void
  sigmaKin( const fptype* allmomenta,      // input: momenta[nevt*npar*4]
            const fptype* allcouplings,    // input: couplings[nevt*ndcoup*2]
            const fptype* allrndhel,       // input: random numbers[nevt] for helicity selection
            const fptype* allrndcol,       // input: random numbers[nevt] for color selection
            fptype* allMEs,                // output: allMEs[nevt], |M|^2 final_avg_over_helicities
#ifdef MGONGPU_SUPPORTS_MULTICHANNEL
            const unsigned int channelId,  // input: multichannel channel id (1 to #diagrams); 0 to disable channel enhancement
            fptype* allNumerators,         // output: multichannel numerators[nevt], running_sum_over_helicities
            fptype* allDenominators,       // output: multichannel denominators[nevt], running_sum_over_helicities
#endif
            int* allselhel,                // output: helicity selection[nevt]
            int* allselcol,                // output: helicity selection[nevt]
            const int nevt );              // input: #events (for cuda: nevt == ndim == gpublocks*gputhreads)
#endif /* clang-format on */

  //--------------------------------------------------------------------------
}

#endif // MG5_Sigma_sm_gu_ttxu_H
