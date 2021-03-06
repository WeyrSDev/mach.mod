superstrict

module mach.filestream
moduleinfo "License: zlib/libpng"
moduleinfo "Author: Sophie Kirschner (sophiek@pineapplemachine.com)"
moduleinfo "8 May 2015: Added to mach.mod"
moduleinfo "11 May 2015: Added FileStream.append function"

import mach.basestream

private
extern "c"
    const SEEK_SET% = 0
    const SEEK_CUR% = 1
    const SEEK_END% = 2
    function cfclose( cfilestream% ) = "fclose"
    function cfread%( buf:byte ptr, size%, count%, cfilestream% ) = "fread"
    function cfwrite%( buf:byte ptr, size%, count%, cfilestream% ) = "fwrite"
    function cfflush%( cfilestream% ) = "fflush"
    function cfseek%( cfilestream%, offset%, origin% ) = "fseek"
    function cftell%( cfilestream% ) = "ftell"
    function cfeof%( cfilestream% ) = "feof"
    function fopen_%( file$, mode$ ) ' Comes from pub.stdc
endextern
public

type FileStream extends BaseStream
    ' faux constants
    const MODE_READ$ = "rb"
    const MODE_WRITE$ = "wb"
    const MODE_APPEND$ = "ab"
    const MODE_READWRITE$ = "r+b"
    const MODE_CREATE$ = "w+b"
    const MODE_READAPPEND$ = "a+b"
    
    field allowread%
    field allowwrite%
    field cfilestream%
    
    method seek%(value%)
        assert cfilestream
        return cfseek(cfilestream, value, SEEK_SET)=0
    end method
    method seekable%()
        return true
    end method
    method flush%()
        assert cfilestream
        return cfflush(cfilestream)=0
    end method
    method close%()
        assert cfilestream
        local status% = cfclose(cfilestream)
        cfilestream = 0
        return status
    end method
    method active%()
        return cfilestream <> 0
    end method
    method pos%()
        assert cfilestream
        return cftell(cfilestream)
    end method
    method size%()
        assert cfilestream
        local current% = cftell(cfilestream)
        cfseek(cfilestream, 0, SEEK_END)
        local value% = cftell(cfilestream)
        cfseek(cfilestream, current, SEEK_SET)
        return value
    end method
    method eof%()
        assert cfilestream
        return cfeof(cfilestream)
    end method
    method readbuffer%(buffer:byte ptr, count%)
        assert cfilestream and count
        if not allowread throw new ReadStreamException
        return cfread(buffer, 1, count, cfilestream)=count
    end method
    method writebuffer%(buffer:byte ptr, count%)
        assert cfilestream and count
        if not allowwrite throw new WriteStreamException
        return cfwrite(buffer, 1, count, cfilestream)=count
    end method
    method skip%(count%)
        assert cfilestream
        return cfseek(cfilestream, count, SEEK_CUR)=0
    end method
    
    method read:FileStream(path$)
        allowread = true
        allowwrite = false
        return openfile(path, MODE_READ)
    end method
    method write:FileStream(path$)
        allowread = false
        allowwrite = true
        return openfile(path, MODE_WRITE)
    end method
    method open:FileStream(path$)
        allowread = true
        allowwrite = true
        return openfile(path, MODE_READWRITE)
    end method
    method create:FileStream(path$)
        allowread = true
        allowwrite = true
        return openfile(path, MODE_CREATE)
    end method
    method append:FileStream(path$)
        allowread = true
        allowwrite = true
        return openfile(path, MODE_READAPPEND)
    end method
    method openfile:FileStream(path$, mode$)
        path=path.Replace( "\","/" )
        cfilestream = fopen_(path, mode)
        if not cfilestream throw new OpenStreamException
        return self
    end method
end type


