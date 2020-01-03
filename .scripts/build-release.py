import re
from pathlib import Path
from typing import Dict, Union
import parse_cmake.parsing as cmp


def parse_file(filename: Path) -> cmp.File:
    return cmp.parse(filename.read_text())


def substitute_include(file_content: cmp.File, ctx: Dict[str, str]) -> cmp.File:
    new_content = cmp.File()
    for entry in file_content:
        if isinstance(entry, cmp._Command) and entry.name == "include":
            new_content.extend(process_file(entry.body[0].contents, ctx))
        else:
            new_content.append(entry)
    return new_content


def process_file(filename_or_arg: Union[Path, str], ctx: Dict[str, str]) -> cmp.File:
    if isinstance(filename_or_arg, Path):
        filename = filename_or_arg
    else:
        filename = Path(substitute_vars(filename_or_arg, ctx))

    return substitute_include(parse_file(filename), ctx)


VAR_RE = re.compile("\$\{(?P<vn>\w+?)\}")


def substitute_vars(input: str, ctx: Dict[str, str]) -> str:
    while True:
        m = VAR_RE.search(input)
        if m is None:
            return input

        s, e = m.span()
        k = m["vn"]

        if k not in ctx:
            raise KeyError(f"{k} is unknown variable name")

        input = "".join([input[:s], ctx[k], input[e:]])


def main():
    current_file = Path(__file__).resolve()
    current_dir = current_file.parent
    main_dir = current_dir.parent
    ctx = {"CMAKE_CURRENT_LIST_DIR": str(main_dir)}
    ctn = process_file(main_dir / "xl.cmake", ctx)
    ctn = f"{ctn}"

    output_dir = main_dir / "release"
    output_dir.mkdir(parents=True, exist_ok=True)
    (output_dir / "xl.cmake").write_text(ctn)


if __name__ == "__main__":
    main()
