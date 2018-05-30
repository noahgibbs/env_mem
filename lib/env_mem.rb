require "env_mem/version"

module EnvMem
  extend self

  def dump_to_file(filename)
    File.open(filename, "w") { |f| f.write GC.stat.inspect }
  end

  def gc_stat_to_shell(stats)
    stats_hash = {}
    stats.scan(/:([a-zA-Z_]+)\s*=>\s*([0-9]+)/).each { |key, val| stats_hash[key] = val.to_i }

    <<SHELL
# gc_params.heap_init_slots
export RUBY_GC_HEAP_INIT_SLOTS=#{stats_hash["heap_live_slots"]}

# gc_params.malloc_limit_min
export RUBY_GC_MALLOC_LIMIT=

# gc_params.oldmalloc_limit_min
export RUBY_GC_OLDMALLOC_LIMIT=

SHELL
  end
end
