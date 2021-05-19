let s:local_path = ''
let s:remote_path = ''
let s:local_path, s:remote_path = split(g:pdb_path_mapping)

func! s:term_execute(cmd, split_cmd, buffer_name)
    if g:pdb_write_debug_log
        echom a:cmd
    endif
    execute(a:split_cmd)
    execute('term ' . a:cmd)
    execute('file ' . g:pdb_module_name . ': ' . a:buffer_name . ' ' . bufnr())
    redraw
endfunc

func! s:system(cmd)
    if g:pdb_write_debug_log
        echom a:cmd
    endif
    return trim(system(a:cmd))
endfunc

func! s:get_current_file_name()
    return expand('%:t')
endfunc

func! s:get_current_django_script_name()
    return join(split(expand('%:r'), '/'), '.')
endfunc

func! s:get_breakpoint(file_name, line_number, condition)
    let result = printf('b %s:%s', a:file_name, a:line_number)
    if !empty(a:condition)
        result = printf('%s, %s', result, a:condition)
    endif
    if !empty(s:local_path) && !empty(s:remote_path)
        let result = substitute(result, s:local_path, s:remote_path, '')
    endif
    return result
endfunc

func s:docker_get_container_id()
    let cmd = printf(
    \   'docker ps -q --filter name=%s', 
    \   pdb#common#get_docker_container_name()
    \)
    return s:system(cmd)
endfunc

func! s:docker_rm_contaner()
    let cmd = printf('docker rm -f %s', pdb#common#get_docker_container_name())
    call s:system(cmd)
endfunc

func! s:docker_compose_run()
    let cmd = printf(
    \   '%s --file=%s run -d --service-ports --use-aliases --name=%s %s bash',
    \   g:pdb_docker_compose_cmd,
    \   g:pdb_docker_compose_file, 
    \   pdb#common#get_docker_container_name(),
    \   g:pdb_docker_compose_service_name
    \)
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
func! s:get_breakpoint_cmd(file_path, line_number, condition)
    let breakpoint = s:get_breakpoint(a:file_name, a:line_number, a:condition)
    return printf('-c "%s"', breakpoint)
endfunc

func! s:get_breakpoints_cmd()
    let results = []
    for [file_name, breakpoints] in items(g:breakpoints_data)
        for breakpoint in breakpoints
            call add(
            \   results, s:get_breakpoint_cmd(breakpoint.file_path, breakpoint.line_number, breakpoint.condition)
            \)
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
    return printf('%s %s', s:get_base_cmd(), pdb#common#get_current_file_path())
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

func! s:get_django_kill_server_cmd()
    return 'pkill -9 -f "manage.py runserver"'
endfunc

func! s:get_docker_django_kill_server_cmd()
    return printf('%s %s', s:get_docker_exec_it_cmd(), s:get_django_kill_server_cmd())
endfunc

" Public functions
func! pdb#debug#copy_breakpoint()
    let @+ = s:get_breakpoint(pdb#common#get_current_file_path(), line('.'), '')
endfunc

func! pdb#debug#script()
    let cmd = s:get_script_cmd()
    call s:term_execute(cmd, g:pdb_debug_script_split_cmd, s:get_current_file_name())
endfunc

func! pdb#debug#django_script()
    let cmd = s:get_django_script_cmd()
    call s:term_execute(cmd, g:pdb_debug_script_split_cmd, s:get_current_file_name())
endfunc

func! pdb#debug#django_server()
    call s:system(s:get_django_kill_server_cmd())
    let cmd = s:get_django_server_cmd()
    call s:term_execute(cmd, g:pdb_debug_django_server_split_cmd, 'django runserver')
endfunc

func! pdb#debug#docker_script()
    let cmd = s:get_docker_script_cmd()
    call s:term_execute(cmd, g:pdb_debug_script_split_cmd, s:get_current_file_name())
endfunc

func! pdb#debug#docker_django_script()
    let cmd = s:get_docker_django_script_cmd()
    call s:term_execute(cmd, g:pdb_debug_script_split_cmd, s:get_current_file_name())
endfunc

func! pdb#debug#docker_django_server()
    call s:system(s:get_docker_django_kill_server_cmd())
    let cmd = s:get_docker_django_server_cmd()
    call s:term_execute(cmd, g:pdb_debug_django_server_split_cmd, 'django runserver')
endfunc
