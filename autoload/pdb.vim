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

func! s:get_current_file_name()
    return fnamemodify(expand("%"), ":~:.")
endfunc

func! s:get_working_dirrectory_name()
    return fnamemodify(getcwd(), ':t')
endfunc

func! s:get_current_django_script_name()
    return join(split(expand('%:r'), '/'), '.')
endfunc

func! s:get_breakpoint(file_name, line_number)
    return printf('b %s:%s', a:file_name, a:line_number)
endfunc

func s:docker_get_container_id()
    let cmd = printf(
    \   'docker ps -q --filter name=%s', 
    \   pdb#GetDockerContainerName()
    \)
    return s:system(cmd)
endfunc

func! s:docker_rm_contaner()
    let cmd = printf('docker rm -f %s', pdb#GetDockerContainerName())
    call s:system(cmd)
endfunc

func! s:docker_compose_run()
    let cmd = printf(
    \   'docker-compose --file=%s run -d --service-ports --use-aliases --name=%s %s bash',
    \   g:pdb_docker_compose_file, 
    \   pdb#GetDockerContainerName(),
    \   g:pdb_docker_compose_service_name
    \)
    if !empty(g:pdb_docker_compose_wrapper_cmd)
        let cmd = printf('%s -- %s', g:pdb_docker_compose_wrapper_cmd, cmd)
    endif
    call s:system(cmd)
endfunc

func! s:docker_compose_run_get_id()
    let result = s:docker_get_container_id()
    if !empty(result)
        return result
    endif

    call s:docker_rm_contaner()
    call s:docker_compose_run()

    let result = s:docker_get_container_id()
    return result
endfunc

" Commands
func! s:get_breakpoint_cmd(file_name, line_number)
    let breakpoint = s:get_breakpoint(a:file_name, a:line_number)
    return printf('-c "%s"', breakpoint)
endfunc

func! s:get_breakpoints_cmd()
    let results = []
    for [file_name, line_numbers] in items(g:breakpoints_data)
        for line_number in line_numbers
            call add(results, s:get_breakpoint_cmd(file_name, line_number))
        endfor
    endfor
    call add(results, '-c "c"')
    return ' ' . join(results)
endfunc

func! s:get_base_cmd()
    return printf('python -m %s%s', g:pdb_module_name, s:get_breakpoints_cmd())
endfunc

func! s:get_django_settings_cmd()
    if !empty(g:pdb_django_settings)
        return ' --settings=' . g:pdb_django_settings
    endif
    return ''
endfunc

func! s:get_django_args_cmd()
    if !empty(g:pdb_django_server_args)
        return ' ' . join(g:pdb_django_server_args)
    endif
    return ''
endfunc

func! s:get_script_cmd()
    return printf('%s %s', s:get_base_cmd(), s:get_current_file_name())
endfunc

func! s:get_django_script_cmd()
    let result = printf(
    \   '%s %s%s %s', 
    \   s:get_base_cmd(), 
    \   'manage.py runscript', 
    \   s:get_django_settings_cmd(), 
    \   s:get_current_django_script_name()
    \)
    return result
endfunc

func! s:get_django_server_cmd()
    let result = printf(
    \   '%s %s %s:%s%s%s', 
    \   s:get_base_cmd(), 
    \   'manage.py runserver', 
    \   g:pdb_django_server_addr, 
    \   g:pdb_django_server_port,
    \   s:get_django_settings_cmd(), 
    \   s:get_django_args_cmd()
    \)
    return result
endfunc

func! s:get_docker_script_cmd()
    return printf('%s %s', s:get_docker_exec_it_cmd(), s:get_script_cmd())
endfunc

func! s:get_docker_django_script_cmd()
    return printf('%s %s', s:get_docker_exec_it_cmd(), s:get_django_script_cmd())
endfunc

func! s:get_docker_exec_it_cmd()
    return printf('docker exec -it %s', s:docker_compose_run_get_id())
endfunc

func! s:get_docker_django_server_cmd()
    return printf('%s %s', s:get_docker_exec_it_cmd(), s:get_django_server_cmd())
endfunc

" Public functions
func! pdb#GetDockerContainerName()
    return printf('%s_%s', s:get_working_dirrectory_name(), g:pdb_module_name)
endfunc

func! pdb#DebugScript()
    echo s:get_script_cmd()
endfunc

func! pdb#DebugDjangoScript()
    echo s:get_django_script_cmd()
endfunc

func! pdb#DebugDjangoServer()
    echo s:get_django_server_cmd()
endfunc

func! pdb#DebugDockerScript()
    echo s:get_docker_script_cmd()
endfunc

func! pdb#DebugDockerDjangoScript()
    echo s:get_docker_django_script_cmd()
endfunc

func! pdb#DebugDockerDjangoServer()
    return s:get_docker_django_server_cmd()
endfunc
