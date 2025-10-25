from utils import resolve_paths, setup_logger, write_csv

paths = resolve_paths()
log = setup_logger()
log.info(f"Data dir: {paths.data_dir}")
write_csv(paths.data_dir / "hello.csv", [{"a": 1, "b": "ok"}], ["a", "b"])
log.info("CSV hello.csv escrito com sucesso.")