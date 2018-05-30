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
export RUBY_GC_HEAP_INIT_SLOTS=#{stats_hash["heap_live_slots"]}
export RUBY_GC_MALLOC_LIMIT=#{stats_hash["malloc_increase_bytes_limit"]}
export RUBY_GC_OLDMALLOC_LIMIT=#{stats_hash["oldmalloc_increase_bytes_limit"]}

SHELL
  end
end
