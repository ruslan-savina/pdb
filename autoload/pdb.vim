let s:python_cmd_items = ['python', '-m', g:pdb_module_name]
let s:django_run_script_cmd_items = ['manage.py', 'runscript']
let s:django_run_server_cmd_items = ['manage.py', 'runserver']

func! s:get_working_dirrectory_name()
    return fnamemodify(getcwd(), ':t')
endfunc

func! s:get_current_file_name()
    return fnamemodify(expand("%"), ":~:.")
endfunc

func! s:get_current_django_script_name()
    return join(split(expand('%:r'), '/'), '.')
endfunc

func! s:get_breakpoint(file_name, line_number)
    let file_name = empty(a:file_name) ? s:get_current_file_name() : a:file_name
    let line_number = empty(a:line_number) ? line('.') : a:line_number
    return 'b ' . file_name . ':' . line_number
endfunc

func! s:get_breakpoint_cmd_items()
    let results = []
    for [file_name, line_numbers] in items(g:breakpoints_data)
        for line_number in line_numbers
            let results += ['-c', printf('"%s"', s:get_breakpoint(file_name, line_number))]
        endfor
    endfor
    return results
endfunc

func! s:get_cmd(items)
    return join(filter(a:items, '!empty(v:val)'))
endfunc

func! s:get_python_cmd_items()
    return s:python_cmd_items + s:get_breakpoint_cmd_items()
endfunc

func! pdb#GetDockerContainerName()
    return printf('%s_%s', s:get_working_dirrectory_name(), g:pdb_module_name)
endfunc

func! pdb#GetRunCurrentScriptCmd()
    return s:get_cmd(add(s:get_python_cmd_items(), s:get_current_file_name()))
endfunc

func! pdb#GetRunCurrentDjangoScriptCmd()
    let items = s:get_python_cmd_items() + s:django_run_script_cmd_items
    if !empty(g:pdb_django_settings)
        call add(items, '--settings=' . g:pdb_django_settings)
    endif
    call add(items, s:get_current_django_script_name())
    return s:get_cmd(items)
endfunc

func! pdb#GetDjangoRunServerCmd()
    let items = s:get_python_cmd_items() + s:django_run_server_cmd_items
    if !empty(g:pdb_django_settings)
        call add(items, '--settings=' . g:pdb_django_settings)
    endif
    if !empty(g:pdb_django_server_args)
        let items += g:pdb_django_server_args
    endif
    call add(items, printf('%s:%s', g:pdb_django_server_addr, g:pdb_django_server_port))
    return s:get_cmd(items)
endfunc
