package com.samwallet.tap;

import android.app.Activity;
import android.nfc.NfcAdapter;
import android.nfc.Tag;
import android.os.Bundle;
import android.view.View;
import android.webkit.WebSettings;
import android.webkit.WebView;

/**
 * Loads the Samsung Wallet UI (assets/index.html) in a WebView and wires the
 * device's real NFC hardware to the payment animation. The animation is only
 * ever fired from {@link #onTagDiscovered}, i.e. when the phone actually senses
 * an NFC field — never on launch and never on a card tap.
 */
public class MainActivity extends Activity implements NfcAdapter.ReaderCallback {

    private WebView webView;
    private NfcAdapter nfcAdapter;
    private boolean pageReady = false;

    private static final int READER_FLAGS =
            NfcAdapter.FLAG_READER_NFC_A |
            NfcAdapter.FLAG_READER_NFC_B |
            NfcAdapter.FLAG_READER_NFC_F |
            NfcAdapter.FLAG_READER_NFC_V |
            NfcAdapter.FLAG_READER_NO_PLATFORM_SOUNDS;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        webView = new WebView(this);
        WebSettings settings = webView.getSettings();
        settings.setJavaScriptEnabled(true);
        settings.setDomStorageEnabled(true);

        webView.setBackgroundColor(0xFF000000);
        webView.setSystemUiVisibility(View.SYSTEM_UI_FLAG_LAYOUT_STABLE);
        webView.setWebViewClient(new android.webkit.WebViewClient() {
            @Override
            public void onPageFinished(WebView view, String url) {
                pageReady = true;
            }
        });

        setContentView(webView);
        webView.loadUrl("file:///android_asset/index.html");

        nfcAdapter = NfcAdapter.getDefaultAdapter(this);
    }

    @Override
    protected void onResume() {
        super.onResume();
        if (nfcAdapter != null) {
            nfcAdapter.enableReaderMode(this, this, READER_FLAGS, null);
        }
    }

    @Override
    protected void onPause() {
        super.onPause();
        if (nfcAdapter != null) {
            nfcAdapter.disableReaderMode(this);
        }
    }

    /** Fired by the platform when an NFC tag/terminal enters the field. */
    @Override
    public void onTagDiscovered(Tag tag) {
        runOnUiThread(() -> {
            if (pageReady && webView != null) {
                webView.evaluateJavascript(
                        "window.onNfcTap && window.onNfcTap();", null);
            }
        });
    }
}
