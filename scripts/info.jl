using JSON
using GoogleCloud
using GoogleCloud.Utils



const FILE_DIR = dirname(@__FILE__())

INFOFileName = joinpath(FILE_DIR,"../assets/info")

run(`gsutil cp gs://neuroglancer/snemi3dtest_v0/segmentation/info $INFOFileName`)

infoDict = JSON.parsefile( INFOFileName )

dl = copy(infoDict["scales"][1])

dl["key"] = "6_6_30_jwu"

push!(infoDict["scales"], dl)

str = JSON.json(infoDict)



write(joinpath(FILE_DIR, "info"), str)

# run(`gsutil cp $(joinpath(FILE_DIR, "info")) gs://neuroglancer/snemi3dtest_v0/segmentation/`)
