import Config

config :venomous, :snake_manager, %{
  # Optional :erlport encoder/decoder for type conversion between elixir/python applied to all workers. The function may also include any :erlport callbacks from python api.
  # It has to be included in the module_paths or PYTHONPATH envvar
  erlport_encoder: %{
    module: :encoder,
    func: :handle_types,
    args: []
  },
  # TTL whenever python process is inactive. Default: 15
  snake_ttl_minutes: 10,
  # Number of python workers that don't get cleared by SnakeManager when their TTL while inactive ends. Default: 10
  perpetual_workers: 10,
  # Interval for killing python processes past their ttl while inactive. Default: 60_000ms (1 min)
  cleaner_interval: 120_000,

  # Erlport python options
  python_opts: [
    # List of paths to your python modules.
    module_paths: [
      "/Users/beltre.wilton/miniforge3/envs/tars_env/lib/python3.10/site-packages",
      "/Users/beltre.wilton/apps/tars/samantha/src",
      "/Users/beltre.wilton/apps/tars/samantha/",
      "/Users/beltre.wilton/apps/tars",
      "/Users/beltre.wilton/apps/plex/python"
    ],
    cd: "/Users/beltre.wilton/apps/tars",
    # Change python's directory on spawn. Default is $PWD
    # cd: "/",
    # Can be set from 0-9. May affect performance. Read more on [Erlport documentation](http://erlport.org/docs/python.html#erlang-api)
    compressed: 0,
    # additional python process envvars
    envvars: [SNAKE_VAR_ONE: "I'm a snake", SNAKE_VAR_TWO: "No, you are not"],
    # Size of erlport python packet. Default: 4 = max 4GB of data. Can also be set to 1 = 256 bytes or 2 = ? bytes if you are sure you won't be transfering a lot of data.
    packet_bytes: 4
    # Change the path to python executable to use.
    # python_executable: ""
  ]
}
