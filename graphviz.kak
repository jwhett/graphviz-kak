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
add-highlighter shared/graphviz/comment-block region '/\*' '\*/' fill value
add-highlighter shared/graphviz/singleq region "'" "'" fill value
add-highlighter shared/graphviz/doubleq region '"' '"' fill value

evaluate-commands %sh{
    # Grammar
    keywords="graph|digraph"

    # Add the language's grammar to the static completion list
    printf %s\\n "declare-option str-list graphviz_static_words ${keywords}" | tr '|' ' '

    # Highlight keywords
    printf %s "add-highlighter shared/graphviz/content/ regex \b(${keywords})\b 0:keyword"
}
echo -d %opt{graphviz_static_words}
}
