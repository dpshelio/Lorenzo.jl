import Lorenzo: smaller_step, extract_date, check_steps,
                dates_directories, create_urls
@testset "scraper" begin
    @testset "steps" begin
        @test smaller_step("y/m/S") == 'S'
        @test smaller_step("H") == 'H'
        @test_throws  ErrorException smaller_step("N")
    end

    @testset "extract" begin
        @test extract_date("this is %Y%d") == "Yd"
        @test extract_date("%m%n/something/%d") == "mnd"
        @test extract_date("There's no pattern") == ""
    end

    @testset "Check" begin
        @test check_steps("md")
        @test check_steps("mnd") == false
    end

    @testset "extractDir" begin
        @test dates_directories("http://my_path/%Y/%m/%d/example%H%M.txt") == "Ymd"
        @test dates_directories("http://my_path/%Y/%m/example%H%M.txt") == "Ym"

    end

    @testset "urls_directories" begin
        url = "http://my_path/%Y/%m/%d/example%H%m.txt"
        dt0 = DateTime(2010,1,1,1,5)
        dt1 = DateTime(2010,1,1,10,5) # 10 hours range
        @test collect(create_urls(url, dt0, dt1)) == ["http://my_path/2010/01/01/"]
        url = "http://my_path/%Y/%m/%d/%H/example%H%m.txt"
        @test collect(create_urls(url, dt0, dt1)) == ["http://my_path/2010/01/01/$(dec(x,2))/" for x in 1:10]
        url = "http://my_path/%Y/%j/example%H%m.txt"
        dt1 = DateTime(2010,2,3,10,5) # 10 hours range
        @test collect(create_urls(url, dt0, dt1)) == ["http://my_path/2010/$(dec(x,3))/" for x in 1:34]

    end
end

