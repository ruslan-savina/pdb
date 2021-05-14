let g:pdb_breakpoints_file_name = '.breakpoints'
let g:pdb_write_debug_log = get(g:, 'pdb_write_debug_log', v:false)
let g:pdb_module_name = get(g:, 'pdb_module_name', 'pdb')
let g:pdb_debug_script_split_cmd = get(g:, 'pdb_debug_script_split_cmd', 'vsp')
let g:pdb_debug_django_server_split_cmd = get(g:, 'pdb_debug_django_server_split_cmd', 'tabnew')

let g:pdb_django_settings = get(g:, 'pdb_django_settings', v:null)
let g:pdb_django_server_addr = get(g:, 'pdb_django_server_addr', '0.0.0.0')
let g:pdb_django_server_port = get(g:, 'pdb_django_server_port', 8000)
let g:pdb_django_server_args = get(g:, 'pdb_django_server_args', ['--noreload', '--nothreading'])

let g:pdb_docker_compose_cmd = get(g:, 'pdb_docker_compose_cmd', 'docker-compose')
let g:pdb_docker_compose_service_name = get(g:, 'pdb_docker_compose_service_name', v:null)
let g:pdb_docker_compose_file = get(g:, 'pdb_docker_compose_file', v:null)
let g:pdb_docker_container_name = get(g:, 'pdb_docker_container_name', pdb#common#get_docker_container_name())

command! PdbDebugScript call pdb#debug#script()
command! PdbDebugDjangoScript call pdb#debug#django_script()
command! PdbDebugDjangoServer call pdb#debug#django_server()
command! PdbDebugDockerScript call pdb#debug#docker_script()
command! PdbDebugDockerDjangoScript call pdb#debug#docker_django_script()
command! PdbDebugDockerDjangoServer call pdb#debug#docker_django_server()

command! PdbBreakpointAdd call pdb#breakpoints#add()
command! PdbBreakpointList call pdb#breakpoints#list()
command! PdbBreakpointDelete call pdb#breakpoints#delete()
command! PdbBreakpointDeleteInBuffer call pdb#breakpoints#delete_in_buffer()
command! PdbBreakpointDeleteAll call pdb#breakpoints#delete_all()
command! PdbBreakpointCopy call pdb#debug#copy_breakpoint()

if !hlexists('Breakpoint')
    call execute('hi Breakpoint guifg=red')
endif

if empty(sign_getdefined('Breakpoint'))
    sign define Breakpoint text=-> texthl=Breakpoint
endif

augroup pdb_breakpoints
    autocmd!
    autocmd BufRead * call pdb#breakpoints#load()
    autocmd BufWrite * call pdb#breakpoints#save()
augroup END
