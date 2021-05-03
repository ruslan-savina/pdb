let s:python_cmd_args = ['python', '-m', g:pdb_module_name]

func! pdb#GetWorkingDirrectoryName()
    return fnamemodify(getcwd(), ':t')
endfunc

func! pdb#GetDockerContainerName()
    return printf('%s_%s', pdb#GetWorkingDirrectoryName(), g:pdb_module_name)
endfunc

func! db#GetCurrentFileName()
    return fnamemodify(expand("%"), ":~:.")
endfunc

func! pdb#GetCurrentDjangoScriptName()
    return join(split(expand('%:r'), '/'), '.')
endfunc

func! pdb#GetBreakpoint(file_name, line_number)
    let file_name = empty(a:file_name) ? s:pdb#GetCurrentFileName() : a:file_name
    let line_number = empty(a:line_number) ? line('.') : a:line_number
    return 'b ' . file_name . ':' . line_number
endfunc

func! pdb#GetBreakpointCmdItems()
    let results = []
    for [file_name, line_numbers] in items(g:breakpoints_data)
        for line_number in line_numbers
            let results += ['-c', printf('"%s"', pdb#GetBreakpoint(file_name, line_number))]
        endfor
    endfor
    return results
endfunc

func! pdb#GetCmd(items)
    return join(filter(a:items, '!empty(v:val)'))
endfunc

func! pdb#GetPythonCmdItems()
    return s:python_cmd_args + pdb#GetBreakpointCmdItems()
endfunc

func! pdb#GetRunCurrentScriptCmd()
    return pdb#GetCmd(add(pdb#GetPythonCmdItems(), s:pdb#GetCurrentFileName()))
endfunc
