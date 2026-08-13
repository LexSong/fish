function gpu-limit --description 'Show the NVIDIA GPU power limit, or set it to the given wattage'
    # nvidia-smi reports the limit as e.g. `450.00`.
    set -l current (nvidia-smi --query-gpu=power.limit --format=csv,noheader,nounits | string trim)

    if not set -q argv[1]
        printf 'Power limit is %.2fW\n' $current
        return
    end

    # `-pl` takes a whole number, so compare against the rounded limit.
    set -l current_int (math "round($current)")
    set -l target (math "round($argv[1])")

    if test $current_int -eq $target
        printf 'Power limit already at %dW\n' $target
    else
        printf 'Setting power limit to %dW (was %dW)\n' $target $current_int
        sudo nvidia-smi -pl $target
    end
end
