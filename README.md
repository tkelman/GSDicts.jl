GSDicts.jl
===========
[![Build Status](https://travis-ci.org/seung-lab/GSDicts.jl.svg?branch=master)](https://travis-ci.org/seung-lab/GSDicts.jl)

use Google Cloud Storage as a key-value store in Julia

# Installation
    Pkg.add("GSDicts")

# Usage
```
using GSDicts
kv  = GSDict("gs://jpwu/test.bigarray.img")
a = rand(UInt8, 50)
kv["test"] = a
b = kv["test"]
```
