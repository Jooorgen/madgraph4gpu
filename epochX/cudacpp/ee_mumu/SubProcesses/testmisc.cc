// Use ./runTest.exe --gtest_filter=*misc to run only this test

#include "mgOnGpuConfig.h"
#include "mgOnGpuVectors.h"
#include "epoch_process_id.h"

#include <gtest/gtest.h>

#include <sstream>
#include <typeinfo>

#ifdef __CUDACC__
#define TESTID( s ) s##_GPU_MISC
#else
#define TESTID( s ) s##_CPU_MISC
#endif

#define XTESTID( s ) TESTID( s )

#ifdef MGONGPU_CPPSIMD
#define EXPECT_TRUE_sv( cond ) { bool_sv mask( cond ); EXPECT_TRUE( maskor ( mask ) ); }
#else
#define EXPECT_TRUE_sv( cond ) { EXPECT_TRUE( cond ); }
#endif

inline const std::string boolTF( const bool& b ){ return ( b ? "T" : "F" ); }

#ifdef MGONGPU_CPPSIMD
inline const std::string boolTF( const bool_v& v )
{
  std::stringstream out;
  out << "{ " << ( v[0] ? "T" : "F" );
  for ( int i=1; i<neppV; i++ ) out << ", " << ( v[i] ? "T" : "F" );
  out << " }";
  return out.str();
}
#endif

TEST( XTESTID( MG_EPOCH_PROCESS_ID ), testmisc )
{
  EXPECT_TRUE( true );

  // Vector initialization for fptype_sv
  {
    fptype_sv f{0};
    EXPECT_TRUE_sv( f == 0 );
  }
  {
    fptype_sv f = fptype_sv{0};
    EXPECT_TRUE_sv( f == 0 );
  }

  // Vector initialization for cxtype_sv
  {
    cxtype_sv c = cxzero_sv();
    EXPECT_TRUE_sv( c.real() == 0 );
    EXPECT_TRUE_sv( c.imag() == 0 );
  }
  {
    cxtype_sv c = cxmake( 1, fptype_sv{0} );
    EXPECT_TRUE_sv( c.real() == 1 );
    EXPECT_TRUE_sv( c.imag() == 0 );
  }
  {
    cxtype_sv c = cxmake( fptype_sv{0}, 1 );
    EXPECT_TRUE_sv( c.real() == 0 );
    EXPECT_TRUE_sv( c.imag() == 1 );
  }
  
  // Array initialization for cxtype_sv array (example: jamp_sv in CPPProcess.cc)
  {
    cxtype_sv array[2] = {}; // all zeros (NB: vector cxtype_v IS initialized to 0, but scalar cxype is NOT, if "= {}" is missing!)
    //std::cout << array[0].real() << std::endl; std::cout << boolTF( array[0].real() == 0 ) << std::endl;
    EXPECT_TRUE_sv( array[0].real() == 0 );
    EXPECT_TRUE_sv( array[0].imag() == 0 );
    EXPECT_TRUE_sv( array[1].real() == 0 );
    EXPECT_TRUE_sv( array[1].imag() == 0 );
  }

  // Alternative array initialization for cxtype_sv array (example: was used for outwf in testxxx.cc)
  {
    cxtype_sv array[2]{}; // all zeros (NB: vector cxtype_v IS initialized to 0, but scalar cxype is NOT, if "{}" is missing!)
    //std::cout << array[0].real() << std::endl; std::cout << boolTF( array[0].real() == 0 ) << std::endl;
    EXPECT_TRUE_sv( array[0].real() == 0 );
    EXPECT_TRUE_sv( array[0].imag() == 0 );
    EXPECT_TRUE_sv( array[1].real() == 0 );
    EXPECT_TRUE_sv( array[1].imag() == 0 );
  }
}
