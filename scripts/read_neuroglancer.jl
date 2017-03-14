using GSDicts

d = GSDict("gs://neuroglancer/golden_v0/image/4_4_40")

data = d["0-64_1024-1088_64-128"]

using ImageMagick

img = ImageMagick.load_(data)

using ImageView

imshow(img[1:64*3,1:64])
