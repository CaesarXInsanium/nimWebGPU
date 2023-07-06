type
  WgpuSType* = enum
    Invalid = 0x00000000,
    SurfaceDescriptorFromMetalLayer = 0x00000001,
    SurfaceDescriptorFromWindowsHWND = 0x00000002,
    SurfaceDescriptorFromXlibWindow = 0x00000003,
    SurfaceDescriptorFromCanvasHTMLSelector = 0x00000004,
    ShaderModuleSPIRVDescriptor = 0x00000005,
    ShaderModuleWGSLDescriptor = 0x00000006,
    PrimitiveDepthClipControl = 0x00000007,
    SurfaceDescriptorFromWaylandSurface = 0x00000008,
    SurfaceDescriptorFromAndroidNativeWindow = 0x00000009,
    SurfaceDescriptorFromXcbWindow = 0x0000000A,
    RenderPassDescriptorMaxDrawCount = 0x0000000F,
    STypeForce32 = 0x7FFFFFFF
  WgpuChainedStruct* = object
    next*: ptr WgpuChainedStruct
    sType*: WgpuSType
  WgpuInstanceDescriptor* = object
    next*: ptr WgpuChainedStruct
  WgpuInstanceImpl = object
  WgpuInstance* = ptr WgpuInstanceImpl
  WgpuPowerPreference* = enum
    Undefined = 0x00000000,
    LowPower = 0x00000001,
    HighPerformance = 0x00000002,
    PowerForce32 = 0x7FFFFFFF
  WgpuRequestAdapterOptions* = object
    next*: ptr WgpuChainedStruct
    surface*: WgpuSurface
    powerPreference*: WgpuPowerPreference
    forceFallbackAdapter*: bool

  WgpuAdapterImpl = object
  WgpuAdapter* = ptr WgpuAdapterImpl
  WgpuRequestAdapterStatus* = enum
    Success = 0x00000000,
    Error = 0x00000001,
    Unknown = 0x00000002,
    StatusForce32 = 0x7FFFFFFF
  # typedef void (*WGPURequestAdapterCallback)(WGPURequestAdapterStatus status, WGPUAdapter adapter, char const * message, void * userdata);
  WgpuRequestAdapterCallback* = proc (status: WgpuRequestAdapterStatus,
      adapter: WgpuAdapter, message: cstring, userData: pointer) {.cdecl.}
  WgpuFeatureName* = enum
    FeatureUndefined = 0x00000000,
    DepthClipControl = 0x00000001,
    Depth32FloatStencil8 = 0x00000002,
    TimestampQuery = 0x00000003,
    PipelineStatisticsQuery = 0x00000004,
    TextureCompressionBC = 0x00000005,
    TextureCompressionETC2 = 0x00000006,
    TextureCompressionASTC = 0x00000007,
    IndirectFirstInstance = 0x00000008,
    ShaderF16 = 0x00000009,
    RG11B10UfloatRenderable = 0x0000000A,
    BGRA8UnormStorage = 0x0000000B,
    FeatureForce32 = 0x7FFFFFFF

  WgpuSurfaceDescriptor* = object
    next*: ptr WgpuChainedStruct
    label*: cstring
  WgpuSurfaceDescriptorFromXlibWindow* = object
    chain*: WgpuChainedStruct
    display*: pointer
    window*: uint32
  WgpuSurfaceImpl = object
  WgpuSurface* = ptr WgpuSurfaceImpl

let libName = "libwgpu_native.so"

{.push, dynlib: libName.}
# WGPU_EXPORT WGPUInstance wgpuCreateInstance(WGPUInstanceDescriptor const * descriptor);
proc wgpuCreateInstance*(descriptor: ptr WGPUInstanceDescriptor): WgpuInstance
  {.importc: "wgpuCreateInstance", cdecl, header: "webgpu.h".}

proc wgpuInstanceDrop*(instance: WgpuInstance) {.importc: "wgpuInstanceDrop",
    cdecl, header: "wgpu.h".}


# void wgpuInstanceRequestAdapter(
# WGPUInstance instance,
# WGPURequestAdapterOptions const * options /* nullable */,
# WGPURequestAdapterCallback callback,
# void * userdata);
proc wgpuInstanceRequestAdapter*(instance: WgpuInstance,
                                options: ptr WgpuRequestAdapterOptions,
                                    callback: WgpuRequestAdapterCallback,
                                        userdata: pointer) {.importc: "wgpuInstanceRequestAdapter",
        cdecl, header: "webgpu.h".}

proc wgpuAdapterDrop*(adapter: WgpuAdapter) {.importc: "wgpuAdapterDrop", cdecl,
    header: "wgpu.h".}

# size_t wgpuAdapterEnumerateFeatures(WGPUAdapter adapter, WGPUFeatureName * features);
proc wgpuAdapterEnumerateFeatures*(adapter: WgpuAdapter,
    features: ptr WgpuFeatureName): uint {.importc: "wgpuAdapterEnumerateFeatures",
    cdecl, header: "webgpu.h".}

# WGPU_EXPORT WGPUSurface wgpuInstanceCreateSurface(WGPUInstance instance, WGPUSurfaceDescriptor const * descriptor);
proc wgpuInstanceCreateSurface*(instance: WgpuInstance,
    descriptor: ptr WGPUSurfaceDescriptor): WgpuSurface {.importc: "wgpuInstanceCreateSurface",
    cdecl, header: "webgpu.h".}
