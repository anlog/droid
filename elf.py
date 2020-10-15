#!/usr/bin/env python
# owner: hello@ifnot.cc
# parse elf needed dynamic libraries
## inspired by https://github.com/facebook/SoLoader/blob/master/java/com/facebook/soloader/MinElf.java

import os, sys
import struct

def usage():
    print('usage: {} <elf_file>'.format(__file__))

def err(msg):
    print('error: {}'.format(msg))
    exit(-1)

def info(msg):
    print('INFO {}'.format(msg))

def getu8(f, offset, little_endian):
    f.seek(offset, 0)
    return struct.unpack('<B' if little_endian else '>B', f.read(1))[0]

def getu16(f, offset, little_endian):
    f.seek(offset, 0)
    return struct.unpack('<H' if little_endian else '>H', f.read(2))[0]

def getu32(f, offset, little_endian):
    f.seek(offset, 0)
    return struct.unpack('<I' if little_endian else '>I', f.read(4))[0]

def getu64(f, offset, little_endian):
    f.seek(offset, 0)
    return struct.unpack('<Q' if little_endian else '>Q', f.read(8))[0]

def getSz(f, offset, little_endian):
    b = getu8(f, offset, little_endian)
    s = ''
    while b != 0:
        s += chr(b)
        offset += 1
        b = getu8(f, offset, little_endian)
    return s

elf_magic = 0x464c457f
default_little_endien = True

def elf_file(elf):
    if os.path.exists(elf):
        with open(elf, 'rb') as f:
            if getu32(f, 0, default_little_endien) != elf_magic:
                err('file {} is not elf'.format(elf))
            else:
                is32 = getu8(f, 4, default_little_endien) == 1
                is_little = getu8(f, 5, default_little_endien) == 1
                byte_order = 'big endian' if not is_little else 'little endian'
                info('{} is32: {}'.format(elf, is32))
                info('{} byte order: {}'.format(elf, byte_order))

                e_phoff = getu32(f, 0x1c, is_little) if is32 else \
                    getu64(f, 0x20, is_little)
                e_phnum = getu16(f, 0x2c, is_little) if is32 else \
                    getu16(f, 0x38, is_little)
                e_phentsize = getu16(f, 0x2a, is_little) if is32 else \
                    getu16(f, 0x36, is_little)

                if e_phnum == 0xFFFF: #overflowed into section[0].sh_info
                    e_shoff = getu32(f, 0x20, is_little) if is32 else \
                        getu64(f, 0x28, is_little)
                    sh_info = getu32(f, e_shoff + 0x1c, is_little) if is32 else \
                        getu32(f, e_short + 0x2c, is_little)
                    e_phnum = sh_info

                dyn_start = 0
                phdr = e_phoff
                for i in range(0, e_phnum):
                    p_type = getu32(f, phdr + 0x0, is_little) if is32 else \
                        getu32(f, phdr + 0x0, is_little)
                    if p_type == 2: # dynamic
                        p_offset = getu32(f, phdr + 0x4, is_little) if is32 else \
                            getu64(f, phdr + 0x8, is_little)
                        dyn_start = p_offset
                        break
                    phdr += e_phentsize

                if dyn_start == 0:
                    info('ELF file does not contain dynamic linking information')
                    exit(0)

                dyn = dyn_start
                nr_DT_NEEDED = 0

                d_tag = getu32(f, dyn + 0x0, is_little) if is32 else \
                    getu64(f, dyn + 0x0, is_little)
                while d_tag != 0:
                    if d_tag == 1:
                        if nr_DT_NEEDED == sys.maxsize:
                            err('malformed DT_NEEDED section')
                        nr_DT_NEEDED += 1
                    elif d_tag == 5:
                        ptr_DT_STRTAB = getu32(f, dyn + 0x4, is_little) if is32 else \
                            getu32(f, dyn + 0x8, is_little)
                    dyn += 0x8 if is32 else 0x10
                    d_tag = getu32(f, dyn + 0x0, is_little) if is32 else \
                        getu64(f, dyn + 0x0, is_little)
                if ptr_DT_STRTAB == 0:
                    info('Dynamic section string-table not found')
                    exit(0)

                phdr = e_phoff
                for i in range(0, e_phnum):
                    p_type = getu32(f, phdr + 0x0, is_little) if is32 else \
                        getu32(f, phdr + 0x0, is_little)
                    if p_type == 1:
                        p_vaddr = getu32(f, phdr + 0x8, is_little) if is32 else \
                            getu64(f, phdr + 0x10, is_little)
                        p_memsz = getu32(f, phdr + 0x14, is_little) if is32 else \
                            getu64(f, phdr + 0x28, is_little)
                        if p_vaddr <= ptr_DT_STRTAB and ptr_DT_STRTAB < p_vaddr + p_memsz:
                            p_offset = getu32(f, phdr + 0x4, is_little) if is32 else \
                                getu64(f, phdr + 0x8, is_little)
                            off_DT_STRTAB = p_offset + (ptr_DT_STRTAB - p_vaddr)
                            break
                    phdr += e_phentsize
                if off_DT_STRTAB == 0:
                    err('did not find file offset of DT_STRTAB table')

                needed = []
                dyn = dyn_start

                d_tag = getu32(f, dyn + 0x0, is_little) if is32 else \
                    getu64(f, dyn + 0x0, is_little)
                while d_tag != 0:
                    if d_tag == 1:
                        d_val = getu32(f, dyn + 0x4, is_little) if is32 else \
                            getu64(f, dyn + 0x8, is_little)
                        needed.append(getSz(f, off_DT_STRTAB + d_val, is_little))
                        if nr_DT_NEEDED == sys.maxsize:
                            err('malformed DT_NEEDED section')
                    dyn += 0x8 if is32 else 0x10
                    d_tag = getu32(f, dyn + 0x0, is_little) if is32 else \
                        getu64(f, dyn + 0x0, is_little)
                if nr_DT_NEEDED != len(needed):
                    err('malformed DT_NEEDED section')
                for i in needed:
                    info('needed libs: {}'.format(i))
                pass
    else:
        err('file {} not found'.format(elf))

def main(argv):
    if len(argv) != 2:
        usage()
    else:
        elf_file(argv[1])

if __name__ == '__main__':
    main(sys.argv)
