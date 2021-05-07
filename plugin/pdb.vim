let g:pdb_write_debug_log = get(g:, 'pdb_write_debug_log', v:false)
let g:pdb_module_name = get(g:, 'pdb_module_name', 'pdb')
let g:pdb_debug_script_split_cmd = get(g:, 'pdb_debug_script_split_cmd', 'vsp')
let g:pdb_debug_django_server_split_cmd = get(g:, 'pdb_debug_django_server_split_cmd', 'tabnew')

let g:pdb_django_settings = get(g:, 'pdb_django_settings', v:null)
let g:pdb_django_server_addr = get(g:, 'pdb_django_server_addr', '0.0.0.0')
let g:pdb_django_server_port = get(g:, 'pdb_django_server_port', 8000)
let g:pdb_django_server_args = get(g:, 'pdb_django_server_args', ['--noreload', '--nothreading'])

let g:pdb_docker_compose_service_name = get(g:, 'pdb_docker_compose_service_name', v:null)
let g:pdb_docker_compose_file = get(g:, 'pdb_docker_compose_file', v:null)
let g:pdb_docker_compose_wrapper_cmd = get(g:, 'pdb_docker_compose_wrapper_cmd', v:null)
let g:pdb_docker_container_name = get(g:, 'pdb_docker_container_name', pdb#GetDockerContainerName())
