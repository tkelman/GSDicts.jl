using JSON

const FILE_DIR = dirname(@__FILE__())

infoDict = JSON.parsefile(joinpath(FILE_DIR,"../assets/info"))
