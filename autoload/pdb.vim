func! s:get_working_dirrectory_name()
    return fnamemodify(getcwd(), ':t')
endfunc

func! pdb#GetDockerContainerName()
    return printf('%s_%s', s:get_working_dirrectory_name(), g:pdb_module_name)
endfunc

let s:python_cmd_items = ['python', '-m', g:pdb_module_name]
let s:django_run_script_cmd_items = ['manage.py', 'runscript']
let s:django_run_server_cmd_items = ['manage.py', 'runserver']

if !empty(g:pdb_docker_compose_file) && !empty(g:pdb_docker_compose_service_name)
    let s:docker_rm_items = ['docker', 'rm', '-f', pdb#GetDockerContainerName()]
    let s:docker_ps_filter_cmd_items = [
    \   'docker', 'ps', '-q', '--filter', printf('name=%s', pdb#GetDockerContainerName())
    \]
    let s:docker_exec_it_cmd_items = ['docker', 'exec', '-it']
    let s:docker_compose_run_cmd_items = [
    \   'docker-compose', 
    \   printf('--file=%s', g:pdb_docker_compose_file), 
    \   'run', '-d', '--service-ports', '--use-aliases', 
    \   printf('--name=%s', pdb#GetDockerContainerName()),
    \   g:pdb_docker_compose_service_name, 'bash'
    \]
endif

func! s:term_execute(cmd, split, name)
    if g:pdb_write_debug_log
        echom a:cmd
    endif
    execute(empty(a:mode) ? 'vsp' : a:split)
    execute('term ' . a:cmd)
    execute('file ' . s:get_option('pdb_debugger', 'pdb') . ': ' . a:name . ' ' . bufnr())
    redraw
endfunc

func! s:system(cmd)
    if g:pdb_write_debug_log
        echom a:cmd
    endif
    return trim(system(a:cmd))
endfunc

func s:get_docker_container_id()
    let cmd = s:get_cmd(s:docker_ps_filter_cmd_items)
    return s:system(cmd)
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

func! s:get_cmd(cmd_items)
    return join(filter(a:cmd_items, '!empty(v:val)'))
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

func! s:get_python_breakpoints_cmd_items()
    return s:python_cmd_items + s:get_breakpoint_cmd_items()
endfunc

func! s:get_run_current_script_cmd_items()
    let results = add(copy(s:get_python_breakpoints_cmd_items()), s:get_current_file_name())
    return results
endfunc

func! s:get_run_current_django_script_cmd_items()
    let results = s:get_python_breakpoints_cmd_items() + s:django_run_script_cmd_items
    if !empty(g:pdb_django_settings)
        call add(results, '--settings=' . g:pdb_django_settings)
    endif
    call add(results, s:get_current_django_script_name())
    return results
endfunc

func! s:get_django_run_server_cmd_items()
    let results = s:get_python_breakpoints_cmd_items() + s:django_run_server_cmd_items
    if !empty(g:pdb_django_settings)
        call add(results, '--settings=' . g:pdb_django_settings)
    endif
    if !empty(g:pdb_django_server_args)
        let results += g:pdb_django_server_args
    endif
    call add(results, printf('%s:%s', g:pdb_django_server_addr, g:pdb_django_server_port))
    return results
endfunc

func! s:docker_rm_contaner()
    let cmd = s:get_cmd(s:docker_rm_items)
    call s:system(cmd)
endfunc

func! s:docker_compose_run()
    let result = s:get_docker_container_id()
    if !empty(result)
        return result
    endif

    call s:docker_rm_contaner()
    let cmd = s:get_cmd(s:docker_compose_run_cmd_items)
    if !empty(g:pdb_docker_compose_wrapper_cmd)
        let cmd = printf('%s -- %s', g:pdb_docker_compose_wrapper_cmd, cmd)
    endif
    call s:system(cmd)

    let result = s:get_docker_container_id()
    return result
endfunc

func! pdb#GetRunCurrentScriptCmd()
    let cmd_items = s:get_run_current_script_cmd_items()
    return s:get_cmd(cmd_items)
endfunc

func! pdb#GetRunCurrentDjangoScriptCmd()
    let cmd_items = s:get_run_current_django_script_cmd_items()
    return s:get_cmd(cmd_items)
endfunc

func! pdb#GetDjangoRunServerCmd()
    let cmd_items = s:get_django_run_server_cmd_items()
    return s:get_cmd(cmd_items)
endfunc
