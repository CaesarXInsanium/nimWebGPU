import nimgl/glfw
import nimgl/glfw/native
import gpu
import os
import strutils
import std/strformat

proc hexptr[T](thing: ptr T): string =
  var n = cast[int64](thing)
  return "0x" & toHex(n)

type
  UserData = object
    adapter: WgpuAdapter
    requestEnded: bool

proc keyProc(window: GLFWWindow, key: int32, scancode: int32,
             action: int32, mods: int32): void {.cdecl.} =
  if key == GLFWKey.ESCAPE and action == GLFWPress:
    window.setWindowShouldClose(true)

proc on_adapter_request_fn(
    status: WgpuRequestAdapterStatus, adapter: WgpuAdapter, message: cstring,
    user_data: pointer): void {.cdecl.} =
  var user_data_ptr = cast[ptr UserData](user_data)
  if status == WgpuRequestAdapterStatus.Success:
    user_data_ptr.adapter = adapter
  else:
    write(stderr, "Failed to do thing")
  user_data_ptr.requestEnded = true

proc request_adapter(instance: WgpuInstance,
    options: ptr WgpuRequestAdapterOptions): WgpuAdapter =
  var user_data = UserData(adapter: nil, requestEnded: false)
  wgpuInstanceRequestAdapter(instance, options, on_adapter_request_fn, cast[
      pointer](user_data.addr()))

  return user_data.adapter


proc main() =
  # GLFW Stuff
  assert glfwInit()
  defer: glfwTerminate()

  glfwWindowHint(GLFWOpenglForwardCompat, GLFW_TRUE) # Used for Mac
  glfwWindowHint(GLFWResizable, GLFW_FALSE)
  glfwWindowHint(GLFW_CLIENT_API, GLFW_NO_API)

  let window: GLFWWindow = glfwCreateWindow(800, 600, "NimGL")
  defer: window.destroyWindow()
  discard window.setKeyCallback(keyProc)

  # WebGPU Stuff
  
  #instance
  var descriptor = WGPUInstanceDescriptor(next: nil)
  var instance = wgpuCreateInstance(addr(descriptor))
  defer: wgpuInstanceDrop(instance)

  # Begin Getting Surface
  # https://github.com/eliemichel/glfw3webgpu/blob/main/glfw3webgpu.c
  var display = glfwGetX11Display()
  var x11window = window.getX11Window()
  var inner_chain = WgpuChainedStruct(next: nil,
      sType: SurfaceDescriptorFromXlibWindow)
  # The code here is sucky as fuck
  var x11desc = WgpuSurfaceDescriptorFromXlibWindow(chain: inner_chain,
      display: display, window: cast[uint32](x11window))
  var surface_descriptor = WgpuSurfaceDescriptor(label: nil, next: cast[
      ptr WgpuChainedStruct](x11desc.addr))
  var surface = wgpuInstanceCreateSurface(instance, surface_descriptor.addr)

  # Begin Betting Adapter
  var adapterOptions = WgpuRequestAdapterOptions(next: nil, surface: nil,
      powerPreference: WgpuPowerPreference.HighPerformance,
      forceFallbackAdapter: false)

  var adapter = request_adapter(instance, adapterOptions.addr)
  defer: wgpuAdapterDrop(adapter)

  # Features
  var feature_count = wgpuAdapterEnumerateFeatures(adapter, nil)
  echo fmt"Features Enabled: {feature_count}"
  var features = newSeq[WgpuFeatureName](feature_count)
  discard wgpuAdapterEnumerateFeatures(adapter, features[0].addr)
  echo "Enabled Features"
  for feat in features:
    echo feat

  if window == nil:
    quit(-1)



  while not window.windowShouldClose:
    glfwPollEvents()


main()
