module DiffEqDiagrams

	using HTTP, JSON, Plots, Pkg

	function imgur(plt)
		savefig(plt, "/tmp/plot.png");
		img_imgur = open("/tmp/plot.png"); 
		r_imgur = HTTP.post("https://api.imgur.com/3/image", ["Authorization"=> "Client-ID $(GLOBAL_IMGUR_KEY)", "Accept"=> "application/json"], img_imgur);
		JSON.parse(String(r_imgur.body))["data"]["link"]
	end

	global GLOBAL_IMGUR_KEY

	function set_imgur_key(key)
		global GLOBAL_IMGUR_KEY = key
	end

	function generate_diagrams(pkg)

		pkgfile_from_pkgname = Base.locate_package(Base.identify_package(pkg))
	    if pkgfile_from_pkgname===nothing
	        if isdir(pkg)
	            pkgdir = pkg
	        else
	            error("No package '$pkg' found.")
	        end
	    else
	        pkgdir = normpath(joinpath(dirname(pkgfile_from_pkgname), ".."))
	    end

	    script = escape_string(joinpath(pkgdir, "diagrams", "diagrams.jl"))
	    diagrams_dir = escape_string(joinpath(pkgdir, "diagrams"))

	    gr()
	    default(show = false)
	    Pkg.activate(diagrams_dir)
	    Pkg.instantiate()
	    include(script)

	    RESULT = Dict()
	    for i in keys(DIAGRAMS)
	    	RESULT[i] = imgur(DIAGRAMS[i])
	    end

	    return RESULT
	end

	export generate_diagrams, set_imgur_key
end # module