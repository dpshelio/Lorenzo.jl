using Lorenzo
using Base.Test

# write your own tests here
function test()
tests = ["scraper.jl"]

    for t in tests
        include("$(t).jl")
    end

end

include("scraper.jl")
