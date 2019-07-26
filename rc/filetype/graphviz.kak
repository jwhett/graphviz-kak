# Detection
# ‾‾‾‾‾‾‾‾‾

hook global BufCreate .*\.(dot) %{
    set-option buffer filetype graphviz
}

# Initialization
# ‾‾‾‾‾‾‾‾‾‾‾‾‾‾

hook global WinSetOption filetype=graphviz %{
    require-module graphviz

    set-option window static_words %opt{graphviz_static_words}

    hook window InsertChar \n -group graphviz-indent graphviz-indent-on-new-line
    hook -once -always window WinSetOption filetype=.* %{ remove-hooks window graphviz-.+ }
}

hook -group graphviz-highlight global WinSetOption filetype=graphviz %{
    add-highlighter window/graphviz ref graphviz
    hook -once -always window WinSetOption filetype=.* %{
        remove-highlighter window/graphviz
    }
}

provide-module graphviz %{

# Highlighters
# ‾‾‾‾‾‾‾‾‾‾‾‾

add-highlighter shared/graphviz regions

add-highlighter shared/graphviz/content default-region group

add-highlighter shared/graphviz/preproc region '#' '$' fill comment
add-highlighter shared/graphviz/comment region '//' '$' fill comment
add-highlighter shared/graphviz/comment-block region '/\*' '\*/' fill comment

add-highlighter shared/graphviz/singleq region "'" "'" fill string
add-highlighter shared/graphviz/doubleq region '"' '"' fill string

add-highlighter shared/graphviz/content/ regex \b([a-zA-Z0-9]+)= 1:rgb:87ceeb+i
add-highlighter shared/graphviz/content/ regex \b(cluster_[a-zA-Z0-9]+)\b 0:rgb:87ceeb+i
add-highlighter shared/graphviz/content/ regex "(->|--)" 0:magenta+b

evaluate-commands %sh{
    # Grammar
    keywords="graph|digraph|rankdir|subgraph|splines"

    # Add the language's grammar to the static completion list
    printf %s\\n "declare-option str-list graphviz_static_words ${keywords}" | tr '|' ' '

    # Highlight keywords
    printf %s "add-highlighter shared/graphviz/content/ regex \b(${keywords})\b 0:keyword"
}

define-command -hidden graphviz-indent-on-new-line %{
    evaluate-commands -draft -itersel %{
        # preserve previous line indent
        try %{
            execute-keys -draft \;K<a-&>
        }
        # If the line above is the start of set, indent with a tab
        try %{
            execute-keys -draft Z k<a-x> <a-k>^[^:]+ \{\s<ret> z i<tab>
        }
    }
    }
}
}
