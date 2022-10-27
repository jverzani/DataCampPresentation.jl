using Mustache, Markdown, JSON
## mustache template for ipynb
ipynb_tpl_colab = mt"""
{
  "nbformat": 4,
  "nbformat_minor": 0,
  "metadata": {
    "accelerator": "GPU",
    "colab": {
      "name": "Julia_1.8.2_template.ipynb",
      "provenance": [],
      "collapsed_sections": [],
      "include_colab_link": true
    },
    "kernelspec": {
      "display_name": "Julia 1.8",
      "language": "julia",
      "name": "julia-1.8"
    },
    "language_info": {
      "file_extension": ".jl",
      "mimetype": "application/julia",
      "name": "julia",
      "version": "1.8.2"
    }
  },
  "cells": [
    {
      "cell_type": "markdown",
      "metadata": {
        "id": "view-in-github",
        "colab_type": "text"
      },
      "source": [
        "<a href=\\\"https://colab.research.google.com/github/jverzani/DataCampPresentation.jl/blob/main/datacamp.ipynb\\\" target=\\\"_parent\\\"><img src=\\\"https://colab.research.google.com/assets/colab-badge.svg\\\" alt=\\\"Open In Colab\\\"/></a><a href=\\\"https://mybinder.org/v2/gh/jverzani/DataCampPresentation.jl/main?labpath&#61;datacamp.ipynb\\\"><img src=\\\"https://mybinder.org/badge_logo.svg\\\" alt=\\\"Binder\\\" /></a>"
      ]
    },
    {
      "cell_type": "code",
      "metadata": {
        "id": "PMGwZ7aFJL8Y"
      },
      "source": [
        "# Installation cell\n",
        "%%capture\n",
        "%%shell\n",
        "if ! command -v julia 3>&1 > /dev/null\n",
        "then\n",
        "    wget -q 'https://julialang-s3.julialang.org/bin/linux/x64/1.8/julia-1.8.2-linux-x86_64.tar.gz' \\\n",
        "        -O /tmp/julia.tar.gz\n",
        "    tar -x -f /tmp/julia.tar.gz -C /usr/local --strip-components 1\n",
        "    rm /tmp/julia.tar.gz\n",
        "fi\n",
        "julia -e 'using Pkg; pkg\\\"add IJulia PlotlyLight DataFrames CSV Chain FreqTables CategoricalArrays; precompile;\\\"'\n",
        "echo 'Done'"
      ],
      "execution_count": 1,
      "outputs": []
    },
    {
      "cell_type": "markdown",
      "metadata": {
        "id": "XdMpcQduyaQc"
      },
      "source": [
        "After you run the first cell (the the cell directly above this text), go to Colab's menu bar and select **Edit** and select **Notebook settings** from the drop down. Select *Julia 1.8* in Runtime type. You can also select your prefered harwdware acceleration (defaults to GPU). \n",
        "\n",
        "<br/>You should see something like this:\n",
        "\n",
        "> ![Colab Img](https://raw.githubusercontent.com/Dsantra92/Julia-on-Colab/master/misc/julia_menu.png)\n",
        "\n",
        "<br/>Click on SAVE\n",
        "<br/>**We are ready to get going**\n",
        "\n",
        "\n",
        "\n"
      ]
    },
    {
      "cell_type": "code",
      "metadata": {
        "id": "iIxu4TjlJnBG",
        "colab": {
          "base_uri": "https://localhost:8080/"
        },
        "outputId": "ddf02770-daba-47a0-e2bf-9947734b3ea5"
      },
      "source": [
        "VERSION"
      ],
      "execution_count": 1,
      "outputs": [
        {
          "output_type": "execute_result",
          "data": {
            "text/plain": [
              "v\\\"1.7.2\\\""
            ]
          },
          "metadata": {},
          "execution_count": 1
        }
      ]
    },
{{{CELLS}}}
  ]
}

"""

ipynb_tpl = ipynb_tpl_colab


## Main function to take a jmd file and turn into a ipynb file
function mdToPynb(io::IO, fname::AbstractString)

    newblocks = Any[]

    out = Markdown.parse_file(fname,  flavor=Markdown.julia)
    for i in 1:length(out.content)
        cell = Dict()
        cell["metadata"] = Dict()
##        cell["prompt_number"] = i

        if isa(out.content[i], Markdown.Code)
            println("==== Block Code ====")
            println(out.content[i])

            txt = out.content[i].code
            lang = out.content[i].language
            cell["cell_type"] = "code"
            cell["execution_count"] = 1
            cell["source"] = [txt]


            cell["outputs"] = []
        else
            cell["cell_type"] = "markdown"
            BigHeader = Union{Markdown.Header{1},Markdown.Header{2}}
            if isa(out.content[i], Markdown.Header)
                d = Dict()
                d["internals"] = Dict()
                if isa(out.content[i], BigHeader)
                    d["internals"]["slide_helper"] = "subslide_end"
                end
                d["internals"]["slide_type"] = "subslide"
                d["slide_helper"]="slide_end"
                d["slideshow"] = Dict()
                d["slideshow"]["slide_type"] = isa(out.content[i], BigHeader) ? "slide" : "subslide"
                cell["metadata"] = d
            end

            result = out.content[i]

            cell["source"] = sprint(io -> Markdown.plain(io, out.content[i]))
#            cell["source"] = sprint(io -> Markdown.html(io, out.content[i]))
        end

cell["source"] == String[""] && println("XXXXXXX")
#        println("Source is ", cell["source"])



        push!(newblocks, JSON.json(cell))
    end

    ## return string
    Mustache.render(io, ipynb_tpl, Dict("CELLS" => join(newblocks, ",\n")))


end


function create_colab()
    open("datacamp.ipynb", "w") do io
        mdToPynb(io, "datacamp.qmd")
    end
end
