#include "CrossSectionKernels.h"

#include "MemoryAccessMatrixElements.h"
#include "MemoryAccessWeights.h"
#include "MemoryBuffers.h"

#include <sstream>

//============================================================================

#ifdef __CUDACC__
namespace mg5amcGpu
#else
namespace mg5amcCpu
#endif
{

  //--------------------------------------------------------------------------

  CrossSectionKernelHost::CrossSectionKernelHost( const BufferWeights& samplingWeights,       // input: sampling weights
                                                  const BufferMatrixElements& matrixElements, // input: matrix elements
                                                  EventStatistics& stats,                     // output: event statistics
                                                  const size_t nevt )
    : CrossSectionKernelBase( samplingWeights, matrixElements, stats )
    , NumberOfEvents( nevt )
  {
    if ( m_samplingWeights.isOnDevice() ) throw std::runtime_error( "CrossSectionKernelHost: samplingWeights must be a host array" );
    if ( m_matrixElements.isOnDevice() ) throw std::runtime_error( "CrossSectionKernelHost: matrixElements must be a host array" );
    if ( this->nevt() != m_samplingWeights.nevt() ) throw std::runtime_error( "CrossSectionKernelHost: nevt mismatch with samplingWeights" );
    if ( this->nevt() != m_matrixElements.nevt() ) throw std::runtime_error( "CrossSectionKernelHost: nevt mismatch with matrixElements" );
  }

  //--------------------------------------------------------------------------

  void CrossSectionKernelHost::updateEventStatistics( const bool debug )
  {
    EventStatistics stats; // new statistics for the new nevt events
    // FIRST PASS: COUNT ALL/ABN/ZERO EVENTS, COMPUTE MIN/MAX
    for ( size_t ievt = 0; ievt < nevt(); ++ievt ) // Loop over all events in this iteration
    {
      const fptype& me = MemoryAccessMatrixElements::ieventAccessConst( m_matrixElements.data(), ievt );
      const fptype& wg = MemoryAccessWeights::ieventAccessConst( m_samplingWeights.data(), ievt );
      const size_t ievtALL = m_iter*nevt() + ievt;
      // The following events are abnormal in a run with "-p 2048 256 12 -d"
      // - check.exe/commonrand: ME[310744,451171,3007871,3163868,4471038,5473927] with fast math
      // - check.exe/curand: ME[578162,1725762,2163579,5407629,5435532,6014690] with fast math
      // - gcheck.exe/curand: ME[596016,1446938] with fast math
      // Debug NaN/abnormal issues
      //if ( ievtALL == 310744 ) // this ME is abnormal both with and without fast math
      //  debug_me_is_abnormal( me, ievtALL );
      //if ( ievtALL == 5473927 ) // this ME is abnormal only with fast math
      //  debug_me_is_abnormal( me, ievtALL );
      m_stats.nevtALL++;
      if ( fp_is_abnormal( me ) )
      {
        if ( debug ) // only printed out with "-p -d" (matrixelementALL is not filled without -p)
          std::cout << "WARNING! ME[" << ievtALL << "] is NaN/abnormal" << std::endl;
        stats.nevtABN++;
        continue;
      }
      if ( fp_is_zero( me ) ) m_stats.nevtZERO++;
      stats.minME = std::min( m_stats.minME, (double)me );
      stats.maxME = std::max( m_stats.maxME, (double)me );
      stats.minWG = std::min( m_stats.minWG, (double)wg );
      stats.maxWG = std::max( m_stats.maxWG, (double)wg );
    }
    // SECOND PASS: COMPUTE MEAN FROM THE SUM OF DIFF TO MIN
    for ( size_t ievt = 0; ievt < nevt(); ++ievt ) // Loop over all events in this iteration
    {
      const fptype& me = MemoryAccessMatrixElements::ieventAccessConst( m_matrixElements.data(), ievt );
      const fptype& wg = MemoryAccessWeights::ieventAccessConst( m_samplingWeights.data(), ievt );
      if ( fp_is_abnormal( me ) ) continue;
      stats.sumMEdiff += ( me - stats.minME );
      stats.sumWGdiff += ( wg - stats.minWG );
    }
    // THIRD PASS: COMPUTE STDDEV FROM THE SQUARED SUM OF DIFF TO MIN
    const double meanME = stats.meanME();
    const double meanWG = stats.meanWG();
    for ( size_t ievt = 0; ievt < nevt(); ++ievt ) // Loop over all events in this iteration
    {
      const fptype& me = MemoryAccessMatrixElements::ieventAccessConst( m_matrixElements.data(), ievt );
      const fptype& wg = MemoryAccessWeights::ieventAccessConst( m_samplingWeights.data(), ievt );
      if ( fp_is_abnormal( me ) ) continue;
      stats.sqsMEdiff += std::pow( me - meanME, 2 );
      stats.sqsWGdiff += std::pow( wg - meanWG, 2 );
    }
    // FOURTH PASS: UPDATE THE OVERALL STATS BY ADDING THE NEW STATS
    m_stats += stats;
    // Increment the iterations counter
    m_iter++;
    // DEBUG PRINTOUTS
    stats.tag = "(NEW) ";
    std::cout << stats;
  }

  //--------------------------------------------------------------------------

}

//============================================================================

#ifdef __CUDACC__
namespace mg5amcGpu
{

  /*
  //--------------------------------------------------------------------------

  CrossSectionKernelDevice::CrossSectionKernelDevice( const BufferWeights& samplingWeights,       // input: sampling weights
                                                      const BufferMatrixElements& matrixElements, // input: matrix elements
                                                      EventStatistics& stats,                     // output: event statistics
                                                      const size_t gpublocks,
                                                      const size_t gputhreads )
    : CrossSectionKernelBase( samplingWeights, matrixElements, stats )
    , NumberOfEvents( gpublocks*gputhreads )
    , m_gpublocks( gpublocks )
    , m_gputhreads( gputhreads )
  {
    if ( ! m_samplingWeights.isOnDevice() ) throw std::runtime_error( "CrossSectionKernelDevice: samplingWeights must be a device array" );
    if ( ! m_matrixElements.isOnDevice() ) throw std::runtime_error( "CrossSectionKernelDevice: matrixElements must be a device array" );
    if ( m_gpublocks == 0 ) throw std::runtime_error( "CrossSectionKernelDevice: gpublocks must be > 0" );
    if ( m_gputhreads == 0 ) throw std::runtime_error( "CrossSectionKernelDevice: gputhreads must be > 0" );
    if ( this->nevt() != m_samplingWeights.nevt() ) throw std::runtime_error( "CrossSectionKernelDevice: nevt mismatch with samplingWeights" );
    if ( this->nevt() != m_matrixElements.nevt() ) throw std::runtime_error( "CrossSectionKernelDevice: nevt mismatch with matrixElements" );
  }

  //--------------------------------------------------------------------------

  void CrossSectionKernelDevice::setGrid( const size_t gpublocks, const size_t gputhreads )
  {
    if ( m_gpublocks == 0 ) throw std::runtime_error( "CrossSectionKernelDevice: gpublocks must be > 0 in setGrid" );
    if ( m_gputhreads == 0 ) throw std::runtime_error( "CrossSectionKernelDevice: gputhreads must be > 0 in setGrid" );
    if ( this->nevt() != m_gpublocks * m_gputhreads ) throw std::runtime_error( "CrossSectionKernelDevice: nevt mismatch in setGrid" );
  }

  //--------------------------------------------------------------------------

  void CrossSectionKernelDevice::updateEventStatistics( const bool debug )
  {
    // Increment the iterations counter
    m_iter++;
  }

  //--------------------------------------------------------------------------
  */

}
#endif

//============================================================================
