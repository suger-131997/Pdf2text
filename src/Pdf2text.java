import java.io.File;
import java.io.IOException;

import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.text.PDFTextStripper;
import org.jruby.Ruby;
import org.jruby.RubyArray;
import org.jruby.embed.ScriptingContainer;

public class Pdf2text {

	public static void main(String[] args) {


		//Rubyインタプリタ起動
	    Ruby r = Ruby.newInstance();
		ScriptingContainer container = new ScriptingContainer();
	    container.runScriptlet(org.jruby.embed.PathType.RELATIVE, "pdf2text.rb");

	    RubyArray rubyAry = (RubyArray) container.callMethod(r.getCurrentContext(), "pdf_search");

	    for(int i = 0; i < rubyAry.length().getIntValue(); i++) {
	    	String pdfFile = "pdf/" + (String) rubyAry.get(i);

	    	try {
			    //PDFドキュメントをロード
			    PDDocument document = PDDocument.load(new File(pdfFile));

			    //テキスト分解クラス生成
			    PDFTextStripper stripper = new PDFTextStripper();
			    //抽出実施
			    String text = stripper.getText(document);


				container.callMethod(r.getCurrentContext(), "pdf2text", text, pdfFile);

			} catch (IOException e) {
			    e.printStackTrace();
			}
	    }

	}

}
