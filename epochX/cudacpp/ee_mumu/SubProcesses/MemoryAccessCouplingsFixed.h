#ifndef MemoryAccessCouplingsFixed_H
#define MemoryAccessCouplingsFixed_H 1

#include "mgOnGpuConfig.h"

#include "mgOnGpuCxtypes.h"

//#include "MemoryAccessHelpers.h"

//----------------------------------------------------------------------------

// A class describing the internal layout of memory buffers for fixed couplings
// This implementation uses a STRUCT[ndcoup][nx2] "super-buffer" layout: in practice, the cIPC global array
// From the "super-buffer" for ndcoup different couplings, use idcoupAccessBuffer to access the buffer for one specific coupling
// [If many implementations are used, a suffix _Sv1 should be appended to the class name]
class MemoryAccessCouplingsFixedBase //_Sv1
{
public:

  // Locate the buffer for a single coupling (output) in a memory super-buffer (input) from the given coupling index (input)
  // [Signature (const) ===> const fptype* iicoupAccessBufferConst( const fptype* buffer, const int iicoup ) <===]
  static __host__ __device__ inline const fptype*
  iicoupAccessBufferConst( const fptype* buffer, // input "super-buffer": in practice, the cIPC global array
                           const int iicoup )
  {
    constexpr int ix2 = 0;
    // NB! this effectively adds an offset "iicoup * nx2"
    return &( buffer[iicoup * nx2 + ix2] ); // STRUCT[idcoup][ix2]
  }

private:

  // The number of floating point components of a complex number
  static constexpr int nx2 = mgOnGpu::nx2;
};

//----------------------------------------------------------------------------

// A class providing access to memory buffers for a given event, based on implicit kernel rules
// Its methods use the KernelAccessHelper template - note the use of the template keyword in template function instantiations
template<bool onDevice>
class KernelAccessCouplingsFixed
{
public:

  // Expose selected functions from MemoryAccessCouplingsFixedBase
  static constexpr auto iicoupAccessBufferConst = MemoryAccessCouplingsFixedBase::iicoupAccessBufferConst;

  // TRIVIAL ACCESS to fixed-couplings buffers
  static __host__ __device__ inline cxtype*
  kernelAccess( fptype* buffer )
  {
    // FIXME: this assumes that ANY cxtype implementation is two adjacent fptypes - is it safer to cast to cxsmpl<fptype>*?
    return reinterpret_cast<cxtype*>( buffer );
  }

  // TRIVIAL ACCESS to fixed-couplings buffers
  static __host__ __device__ inline const cxtype*
  kernelAccessConst( const fptype* buffer )
  {
    // FIXME: this assumes that ANY cxtype implementation is two adjacent fptypes - is it safer to cast to cxsmpl<fptype>*?
    return reinterpret_cast<const cxtype*>( buffer );
  }
};

//----------------------------------------------------------------------------

typedef KernelAccessCouplingsFixed<false> HostAccessCouplingsFixed;
typedef KernelAccessCouplingsFixed<true> DeviceAccessCouplingsFixed;

//----------------------------------------------------------------------------

#endif // MemoryAccessCouplingsFixed_H
