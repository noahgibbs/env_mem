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
# gc_params.heap_free_slots
export RUBY_GC_HEAP_FREE_SLOTS=#{stats_hash["heap_available_slots"]}

# gc_params.heap_init_slots
export RUBY_GC_HEAP_INIT_SLOTS=

# gc_params.growth_factor
export RUBY_GC_HEAP_GROWTH_FACTOR=

# gc_params.gc_params.growth_max_slots
export RUBY_GC_HEAP_GROWTH_MAX_SLOTS=

# gc_params.heap_free_slots_min_ratio - between 0.0 and 1.0, default 1.0, 0.0 not allowed
export RUBY_GC_HEAP_FREE_SLOTS_MIN_RATIO=

# gc_params.heap_free_slots_max_ratio - between 0.0 and 1.0, default 0.0 0.0 not allowed
export RUBY_GC_HEAP_FREE_SLOTS_MAX_RATIO=

# gc_params.heap_free_slots_goal_ratio - between min and max ratio, 0.0 allowed
export RUBY_GC_HEAP_FREE_SLOTS_GOAL_RATIO=

# gc_params.oldobject_limit_factor
export RUBY_GC_HEAP_OLDOBJECT_LIMIT_FACTOR=

# gc_params.malloc_limit_min
export RUBY_GC_MALLOC_LIMIT=

# gc_params.malloc_limit_max
export RUBY_GC_MALLOC_LIMIT_MAX=

# gc_params.malloc_limit_growth_factor
export RUBY_GC_MALLOC_LIMIT_GROWTH_FACTOR=

# gc_params.oldmalloc_limit_min
export RUBY_GC_OLDMALLOC_LIMIT=

# gc_params.oldmalloc_limit_max
export RUBY_GC_OLDMALLOC_LIMIT_MAX=

# gc_params.oldmalloc_limit_growth_factor
export RUBY_GC_OLDMALLOC_LIMIT_GROWTH_FACTOR=
SHELL
  end
end
