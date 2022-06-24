module mpi

fn switch_mpi() ? {
        if is_on() { return }

        return start()
}

fn test_mpi() {
        switch_mpi() or {}
}
