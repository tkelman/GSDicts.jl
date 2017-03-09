using GSDicts

d = GSDict("gs://neuroglancer/golden_v0/image/4_4_40/")

data = d["0-64_1024-1088_128-192"]


# # read directly in local
# f = open(joinpath(dirname(@__FILE__()), "../assets/0-64_1024-1088_128-192"))
# data = read(f)
# close(f)

using ImageMagick
a = ImageMagick.load_(data)
using ImageView
imshow(a[1:64*5,1:64])
# a = reshape(a, (64*64,64))

using Libz
Libz.decompress(data[1:end])
img = read( data[17:end] |> ZlibInflateInputStream )

img = reshape(img, (64,64,64))


using GSDicts
using Libz
a = Vector{UInt8}([0,1,2,3])
data2 = Libz.compress(a)
write("test.local.libz", data2)

d2 = GSDict("gs://jpwu/test/")

d2["test.double"] = rand(5,5)

d2["test.libz"] = data2

Libz.decompress(data2)

data3 = d2["test.libz"]

f = open(joinpath(dirname(@__FILE__()), "../assets/test.libz"))
data3 = read(f)
close(f)

Libz.decompress(data3[3:end])
