package main

import "core:log"
import "core:mem"
import "core:mem/virtual"
import "core:net"
import "core:thread"

// smoke test
main :: proc() {

	context.logger = log.create_console_logger()
	log.debug("Protohackers - smoke test")

	pool: thread.Pool
	thread.pool_init(&pool, allocator = context.allocator, thread_count = 5)
	defer thread.pool_destroy(&pool)
	thread.pool_start(&pool)

	//berkeley socket server side
	server_endpoint := net.Endpoint{net.IP4_Address{0, 0, 0, 0}, 8080}
	tcp_socket, listen_err := net.listen_tcp(server_endpoint)
	log.assert(listen_err == nil, "I can't listen on socket")
	log.debugf("start listening on %v", server_endpoint)


	for {
		//block until connection is established
		client_socket, client_endpoint, accept_error := net.accept_tcp(tcp_socket)
		defer net.close(client_socket)
		if accept_error != nil {
			log.errorf("I got an error when accepting client %v", accept_error)
			continue
		}

		// prepare memory for client task
		client_arena: virtual.Arena
		err_arena_init := virtual.arena_init_growing(&client_arena, 1 * mem.Kilobyte)
		if err_arena_init != nil {
			log.errorf("I can't create arena allocator: %v", err_arena_init)
			continue
		}
		client_allocator := virtual.arena_allocator(&client_arena)

		// prepare data to send to client task
		client_data, alloc_error := new(ClientData, client_allocator)
		if alloc_error != nil {
			log.error("cannot allocate data for client")
			continue
		}
		client_data.endpoint = client_endpoint
		client_data.socket = client_socket

		// start client task  
		thread.pool_add_task(
			&pool,
			allocator = client_allocator,
			procedure = task_echo,
			data = client_data, // its already a pointer on data
		)
	}
}

ClientData :: struct {
	endpoint: net.Endpoint,
	socket:   net.TCP_Socket,
}
task_echo :: proc(t: thread.Task) {
	context.logger = log.create_console_logger()
	client_data := cast(^ClientData)t.data
	log.debugf("client connected %v", client_data.endpoint)
	net.close(client_data.socket)
}
