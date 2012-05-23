# -*- coding: latin-1 -*-

error_dict = {
    CLFFT_SUCCESS: 'no error',
    CLFFT_BUGCHECK: 'Bugcheck',
    CLFFT_NOTIMPLEMENTED: 'Functionality is not implemented yet.',
    CLFFT_TRANSPOSED_NOTIMPLEMENTED: 'Transposed functionality is not implemented for this transformation.',
    CLFFT_FILE_NOT_FOUND: 'Tried to open an existing file on the host system, but failed.',
    CLFFT_FILE_CREATE_FAILURE: 'Tried to create a file on the host system, but failed.',
    CLFFT_VERSION_MISMATCH: 'Version conflict between client and library.',
    CLFFT_INVALID_PLAN: 'Requested plan could not be found.',
    CLFFT_DEVICE_NO_DOUBLE: 'Double precision not supported on this device.',
    }

class GpyFFT_Error(Exception):
    def __init__(self, errorcode):
        self.errorcode = errorcode

    def __str__(self):
        return repr(error_dict.get(self.errorcode))

cdef inline bint errcheck(clAmdFftStatus result) except True:
    cdef bint is_error = (result != CLFFT_SUCCESS)
    if is_error:
        raise GpyFFT_Error(result)
    return is_error

class GpyFFT(object):
    def __cinit__(self):
        cdef clAmdFftSetupData setup_data
        errcheck(clAmdFftInitSetupData(&setup_data))
        errcheck(clAmdFftSetup(&setup_data))

    def __dealloc__(self):
        errcheck(clAmdFftTeardown())

    def get_version(self):
        cdef cl_uint major, minor, patch
        errcheck(clAmdFftGetVersion(&major, &minor, &patch))
        return (major, minor, patch)
    
    def create_plan(self, context, array):
        return Plan(context, array)
     
        
cdef class Plan(object):

    cdef clAmdFftPlanHandle plan

    def __dealloc__(self):
        if self.plan:
            errcheck(clAmdFftDestroyPlan(&self.plan))

    def __cinit__(self):
        self.plan = 0

    def __init__(self, context, array):
        cdef cl_context _context = <cl_context>context.obj_ptr
        cdef size_t lengths[3]

        ndim = array.ndim
        _ndim = {1: CLFFT_1D, 2: CLFFT_2D, 3: CLFFT_3D}[ndim] #TODO: errcheck
        shape = array.shape

        for i in range(ndim):
            lengths[i] = shape[i]

        errcheck(clAmdFftCreateDefaultPlan(&self.plan,
                                           _context,
                                           _ndim,
                                           lengths, 
                                            ))





#cdef Plan PlanFactory():
    #cdef Plan instance = Plan.__new__(Ref)
    #instance plan = None
    #return instance
#    pass
