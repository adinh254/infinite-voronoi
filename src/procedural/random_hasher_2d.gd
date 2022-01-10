class_name RandomHasher2D
extends HashingContext

var hash_seed: int = randi()
var _stream_buffer := StreamPeerBuffer.new() setget private_set


func hash_2di(p_x: int, p_y: int) -> int:
	# Hash algorithm using md5.
	_stream_buffer.clear()
	_stream_buffer.put_64(p_x ^ hash_seed)
	_stream_buffer.put_64(p_y ^ hash_seed)
	# warning-ignore:return_value_discarded
	start(HashingContext.HASH_MD5)
	# warning-ignore:return_value_discarded
	update(_stream_buffer.data_array)
	return hash(finish().hex_encode())


func private_set(_value=null):
	print("ERROR: Access to Private Variable.")
	print_stack()
	pass
