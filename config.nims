import os

var dir = getCurrentDir()

switch("threads", "on")
switch("define", "release")
switch("outdir", "build")
switch("clibdir", dir & "/wgpu")
switch("cincludes", dir & "/wgpu")

switch("passL", dir & "/wgpu/libwgpu_native.so")
