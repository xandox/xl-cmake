import re
from pathlib import Path
from typing import List, Any, Dict
from parse_cmake import parsing as cmp

VAR_RE = re.compile("\$\{(?P<vn>\w+?)\}")


def parse_file(filename: Path) -> cmp.File:
    return cmp.parse(filename.read_text())


def replace_includes(content: cmp.File, ctx: Dict[str, str]) -> cmp.File:
    new_content = cmp.File()
    for entry in content:
        if isinstance(entry, cmp._Command) and entry.name == "include":
            new_content.extend(process_file(entry.body[0].contents, ctx))
        else:
            new_content.append(entry)

    return new_content


def substitute_cmake_vars(input: str, ctx: Dict[str, str]) -> str:
    while True:
        m = VAR_RE.search(input)
        if m is None:
            return input

        s, e = m.span()
        k = m["vn"]
        if k not in ctx:
            raise KeyError(f"{k} unknown VARIABLE name")

        input = "".join([input[:s], ctx[k], input[e:]])


def process_file(filename: str, ctx: Dict[str, str]) -> cmp.File:
    filename = Path(substitute_cmake_vars(filename, ctx))
    file_list = parse_file(filename)
    return replace_includes(file_list, ctx)


def main():
    current_file = Path("__file__").resolve()
    current_dir = current_file.parent
    output_dir = current_dir / "output"
    output_dir.mkdir(parents=True, exist_ok=True)
    main_dir = current_dir.parent
    ctx = {"CMAKE_CURRENT_LIST_DIR": str(main_dir)}
    full_content = process_file(str(main_dir / "xl.cmake"), ctx)
    full_content = f"{full_content}"
    (output_dir / "xl.cmake").write_text(full_content)


if __name__ == "__main__":
    main()
