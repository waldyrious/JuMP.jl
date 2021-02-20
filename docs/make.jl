using Documenter
using Literate
using JuMP
using Test

# Pass --fast as an argument to skip rebuilding the examples and running
# doctests. Only use this argument to rapidly test small changes to the
# Markdown. _Never_ set it in production.
const _FAST = findfirst(isequal("--fast"), ARGS) !== nothing

const _EXAMPLE_DIR = joinpath(@__DIR__, "src", "examples")
const _EXAMPLE_SUBDIR = [
    "Mixed-integer linear programs",
    "Nonlinear programs",
    "Quadratic programs",
    "Semidefinite programs",
]

const _TUTORIAL_DIR = joinpath(@__DIR__, "src", "tutorials")

function link_example(content)
    edit_url = match(r"EditURL = \"(.+?)\"", content)[1]
    footer = match(r"^(---\n\n\*This page was generated using)"m, content)[1]
    content = replace(
        content, footer => "[View this file on Github]($(edit_url)).\n\n" * footer
    )
    return content
end

function _file_list(full_dir, relative_dir, extension)
    return map(
        file -> joinpath(relative_dir, file),
        filter(file -> endswith(file, extension), sort(readdir(full_dir))),
    )
end

function literate_directory(dir)
    rm.(_file_list(dir, dir, ".md"))
    for filename in _file_list(dir, dir, ".jl")
        # `include` the file to test it before `#src` lines are removed. It is
        # in a testset to isolate local variables between files.
        @testset "$(filename)" begin
            include(filename)
        end
        Literate.markdown(
            filename,
            dir;
            documenter = true,
            postprocess = link_example,
        )
    end
    return nothing
end

if !_FAST
    literate_directory(_EXAMPLE_DIR)
    literate_directory.(joinpath.(_EXAMPLE_DIR, _EXAMPLE_SUBDIR))
    literate_directory(joinpath(_TUTORIAL_DIR, "Getting started"))
    literate_directory(joinpath(_TUTORIAL_DIR, "Mixed-integer linear programs"))
    literate_directory(joinpath(_TUTORIAL_DIR, "Optimization concepts"))
end

makedocs(
    sitename = "JuMP",
    authors = "Miles Lubin, Iain Dunning, and Joey Huchette",
    format = Documenter.HTML(
        # See https://github.com/JuliaDocs/Documenter.jl/issues/868
        prettyurls = get(ENV, "CI", nothing) == "true",
        analytics = "UA-44252521-1",
        collapselevel = 1,
    ),
    # `strict = true` causes Documenter to throw an error if the Doctests fail.
    strict = true,
    # ==========================================================================
    # `modules = [JuMP]`, along with `checkdocs = :exports` causes Documenter to
    # thow an error if exported functions with docstrings are not contained in
    # the Documentation. However, problematically, we include some MOI docs,
    # which forces us to include MOI in `modules`, despite the fact that we
    # don't necessarily want to document every MOI method.
    #
    # This is should be fine for now, because MOI doesn't export anything.
    # However, also problematically, some doctests in MOI are not checked and
    # are failing. Until they are fixed, we can't enable these options.
    #
    # TODO(odow): uncomment when possible.
    # modules = [JuMP, MOI],
    # checkdocs = :exports,
    # ==========================================================================
    # Skip doctests if --fast provided.
    doctest = !_FAST,
    pages = [
        "Introduction" => "index.md",
        "installation.md",
        "Manual" => [
            "manual/models.md",
            "manual/variables.md",
            "manual/expressions.md",
            "manual/objective.md",
            "manual/constraints.md",
            "manual/containers.md",
            "manual/solutions.md",
            "manual/nlp.md",
            "manual/callbacks.md",
        ],
        "Tutorials" => map(
            subdir -> subdir => map(
                file -> joinpath("tutorials", subdir, file),
                filter(
                    file -> endswith(file, ".md"),
                    sort(readdir(joinpath(_TUTORIAL_DIR, subdir))),
                ),
            ),
            ["Getting started", "Mixed-integer linear programs", "Optimization concepts"],
        ),
        "Examples" => vcat(
            _file_list(_EXAMPLE_DIR, "examples", ".md"),
            map(
                subdir -> subdir => _file_list(
                    joinpath(_EXAMPLE_DIR, subdir),
                    joinpath("examples", subdir),
                    ".md",
                ),
                _EXAMPLE_SUBDIR,
            ),
        ),
        "API Reference" => [
            "reference/models.md",
            "reference/variables.md",
            "reference/expressions.md",
            "reference/objectives.md",
            "reference/constraints.md",
            "reference/containers.md",
            "reference/solutions.md",
            "reference/nlp.md",
            "reference/callbacks.md",
            "reference/moi.md",
        ],
        "Developer Docs" => [
            "Extensions" => "developers/extensions.md",
            "Style Guide" => "developers/style.md",
            "Roadmap" => "developers/roadmap.md",
        ],
    ],
)

deploydocs(
    repo   = "github.com/jump-dev/JuMP.jl.git",
    push_preview = true,
)
