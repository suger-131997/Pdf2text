# coding: Shift_JIS

def pdf2text(t, pdffile)
    #フォルダ作成
    dirname = pdffile.gsub(/.pdf/, "")
    dirname = dirname.gsub(/pdf\//, "")
    if !Dir.exist?(dirname) then
        Dir.mkdir(dirname)
    end

    #本文格納
    text = "" + t

    #改行コード
    text = text.gsub(/\r/, "")
    #text = text.gsub(/\u00A0/, " ")
    #text = text.gsub(/\u00AD/, "-")

    #章分け
    chapters = Hash.new

    key = "Title\n"
    value = ""

    flow = Array.new
    flow << key
    mode_chap = 0

    File.open("option/"+dirname + ".txt", "r") do |f|
        f.each_line do |line|
            l = line.gsub(/\r/, "")
            if l =~ /^mode_chap=(\d)\n$/ then
                mode_chap = $1.to_i
            else
                flow << line.gsub(/\r/, "")
            end
        end
    end
    #p mode_chap
    chapID = 1
    text.each_line do |line|
        if line =~ /^[1-9]\.\d.*/ then
            #p line
        end
        if mode_chap == 0 then  #全文一致
            #p line
            if line == flow[chapID] then
                p line
                chapters.store(key, value)
                key = line
                value = ""
                flow[chapID] = key
                chapID = chapID + 1
            else
                if line !~ /^\d\n$/ then
                    value += line
                end
            end
        elsif mode_chap == 1 then   #先頭一致
            #p line
            if flow[chapID] != nil && line.start_with?(flow[chapID].gsub(/\n/, "") ) then
                p line
                chapters.store(key, value)
                key = line
                value = ""
                flow[chapID] = key
                chapID = chapID + 1
            else
                if line !~ /^\d\n$/ then
                    value += line
                end
            end
        end
    end

    chapters.store(key, value)


    flow.each do |key|
        if key != "Title\n" then
            #改行の単語の分割除去
            chapters.store(key, chapters[key].gsub(/([a-zA-Z])-\n/){ $1 })
            #ピリオド直後以外の改行を消す
            chapters.store(key, chapters[key].gsub(/([^\.])\n/){ $1 + " " })
            #ピリオド直後に改行
            chapters.store(key, chapters[key].gsub(/\.\s([A-Z])/){ ".\n" + $1 })
            #e.g.\nへの対応
            chapters.store(key, chapters[key].gsub(/e\.g\.\n/){ "e.g." })
        end
    end


    #同名ファイル作成
    filename = dirname +"/" + dirname + ".txt"

    File.open(filename, "w") do |f|
        flow.each do |key|
            f.puts key
            f.puts chapters[key]
            f.puts ""
        end
    end

    #1文ごとに改行
    flow.each do |key|
        if key != "Title\n" then
            #()を除去
            chapters.store(key, chapters[key].gsub(/\.\n/){ ".\n\n" })
        end
    end

    #ファイル名変更
    filename = dirname +"/"  + dirname +  "_dif.txt"

    File.open(filename, "w") do |f|
        flow.each do |key|
            f.puts key
            f.puts chapters[key]
            f.puts ""
        end
    end
=begin
    #()を除去
    flow.each do |key|
        if key != "Title\n" then
            #()を除去
            chapters.store(key, chapters[key].gsub(/\([^)]*\)/){ "" })
        end
    end

    #ファイル名変更
    filename = dirname +"/"  + dirname +  "_no_()_dif.txt"

    File.open(filename, "w") do |f|
        flow.each do |key|
            f.puts key
            f.puts chapters[key]
            f.puts ""
        end
    end
=end
end

def pdf_search()
    pdfs = []
    Dir.open("pdf") do |dir|
        dir.each do |f|
            if f =~ /.*.pdf$/ then
                pdfs << f
            end
        end
    end
    return pdfs
end