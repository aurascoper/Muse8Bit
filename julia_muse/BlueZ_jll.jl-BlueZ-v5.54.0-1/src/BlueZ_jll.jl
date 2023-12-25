# Use baremodule to shave off a few KB from the serialized `.ji` file
baremodule BlueZ_jll
using Base
using Base: UUID
import JLLWrappers

JLLWrappers.@generate_main_file_header("BlueZ")
JLLWrappers.@generate_main_file("BlueZ", UUID("471b5b61-da80-5748-8755-67d5084d21f2"))
end  # module BlueZ_jll
