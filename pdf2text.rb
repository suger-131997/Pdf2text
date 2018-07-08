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

    #文字化けへの対応
    #text = text.gsub(/\u00A0/, " ")
    #text = text.gsub(/\u00AD/, "-")

    #章分け
    chapters = Hash.new

    #タイトル部分のため
    key = "Title\n"

    #見出し用ファイルから見出しをロード
    flow = Array.new
    flow << key
    mode_chap = 0

    File.open("option/"+dirname + ".txt", "r") do |f|
        f.each_line do |line|
            #p line
            if line =~ /^mode_chap=(\d).*\n$/ then
                mode_chap = $1.to_i
            else
                flow << line.gsub(/\r/, "").gsub(/\n/, "") + "\n"
            end
        end
    end
    #p flow
    #p mode_chap

    #章ごとにテキスト分割
    value = ""                       #本文仮格納用
    chapID = 1
    text.each_line do |line|
        if line =~ /^[1-9]\.\d.*/ then
            #p line
        end
        if mode_chap == 0 then  #全文一致
            #p line
            if line == flow[chapID] then
                #p line
                chapters.store(key, value)
                key = line
                value = ""
                chapID = chapID + 1
            else
                #ページ番号でなければ本文に追加
                if line !~ /^\d\n$/ then
                    value += line
                end
            end
        elsif mode_chap == 1 then   #先頭一致
            #p line
            if flow[chapID] != nil && line.start_with?(flow[chapID].gsub(/\n/, "") ) then
                #p line
                chapters.store(key, value)
                key = line
                value = ""
                chapID = chapID + 1
            else
                #ページ番号でなければ本文に追加
                if line !~ /^\d\n$/ then
                    value += line
                end
            end
        end
    end

    #最後の章追加
    chapters.store(key, value)

    #章題不一致
    if chapID != flow.length then
        puts "not found chapter name: #{flow[chapID]}\n"
        exit(0)
    end

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
    puts "Pdf to text success"
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