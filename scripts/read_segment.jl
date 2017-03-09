using GSDicts

d = GSDict("gs://neuroglancer/golden_v0/segmentation/4_4_40")

data = d["0-64_1024-1088_64-128"]

# using Libz

data = reinterpret(UInt32, data)

data = reshape(data, (64,64,64))

using EMIRT

img = EMIRT.seg2rgb(data)

using ImageView

imshow(img)
