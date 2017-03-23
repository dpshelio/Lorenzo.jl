# %j is number of days in year
global time_step = Dict('s' => (Dates.Millisecond, 3), 'S' => (Dates.Second, 2),
                    'M' => (Dates.Minute, 2), 'H' => (Dates.Hour, 2),
                    'd' => (Dates.Day, 2), 'j' => (Dates.Day, 3),
                    'U' => (Dates.Month, 1), 'u' => (Dates.Month, 1), 'm' => (Dates.Month, 2),
                    'Y' => (Dates.Year, 1), 'y' => (Dates.Year, 2))
global date_steps = ['s', 'S', 'M', 'H',
                     'd', 'j', 'U', 'u', 'm', 'Y', 'y']
# ^^ Not using keys(time_step) because dict is not ordered. #FIXME change to ordict

function smaller_step{T <: String}(pattern::T)
    # list of date steps in increasing order
    # Loop over all the possibles step and
    # return the smallest one.
    for step in date_steps
        if step in pattern
            return step
        end
    end
    error("Date pattern $(pattern) not encountered")
end

function extract_date{T <: String}(text::T)
    # Look up for %X patterns to convert to date
    dates = collect(matchall(r"%.", text)) |> join
    replace(dates, "%", "")
end

function check_steps{T <: String}(text::T)
    # Check whether all %pattern are dates
    all(x->x in date_steps, text)
end

"""
    dates_directories(urlpattern)

Extracts the dates patterns from an url pattern
# Example
```jldoctest
julia> dates_directories("http://this.is/my/%Y/%m/%d/ofBirth.txt")
"Ymd"
```
"""
function dates_directories{T <: String}(urlpattern::T)
    directories = collect(matchall(r"%.*/", urlpattern)) |> join
    extract_date(directories)
end

"""
    create_urls(urlpattern, timeStart, timeEnd)

Generates urls directories where to look for a particular time
range.
# Example
```jldoctest
julia> dt0, dt1 = DateTime(2017, 2, 3), DateTime(2017, 2, 5)
julia> create_urls("http://this.is/my/%Y/%m/%d/ofBirth.txt", dt0, dt1)
3-element Array{String, 1}:
 "http://this.is/my/2017/02/03/"
 "http://this.is/my/2017/02/04/"
 "http://this.is/my/2017/02/05/"
```
"""
function create_urls{T <: String, DT <: Base.Dates.TimeType}(urlpattern::T, timeStart::DT, timeEnd::DT)
    #NOTE Should the steprange preceed over urlpattern?

    # Find directory step range
    dates = dates_directories(urlpattern)
    if check_steps(dates)
        step = smaller_step(dates)
    end

    # Only extract the directory path
    urlpattern_dir = matchall(r".*/", urlpattern)[1]
    function convert_url(tstep)
        myurl = urlpattern_dir
        for date in dates
            # replace each date bit; day of year implemented manually
            myurl = replace(myurl, "%$(date)", date == 'j' ? dec(Dates.dayofyear(tstep), 3) : Dates.format(tstep, "$(date)" ^ time_step[step][2]))
        end
        return myurl
    end

    dt = timeStart:time_step[step][1](1):timeEnd
    map(convert_url, dt)

end
