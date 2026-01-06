//
//  MarkdownWebView.swift
//  Repomance
//
//  Renders markdown with HTML support using marked.js
//

import SwiftUI
import WebKit
import SafariServices

struct MarkdownWebView: UIViewRepresentable {
    let markdown: String
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        webView.scrollView.isScrollEnabled = true
        webView.navigationDelegate = context.coordinator
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        // Use base64 encoding to safely pass markdown without escaping issues
        let markdownData = markdown.data(using: .utf8) ?? Data()
        let base64Markdown = markdownData.base64EncodedString()
        
        let html = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
            <script src="https://cdn.jsdelivr.net/npm/marked@11.1.1/marked.min.js"></script>
            <style>
                * { box-sizing: border-box; }
                body {
                    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Helvetica, Arial, sans-serif;
                    font-size: 14px;
                    line-height: 1.6;
                    color: #24292f;
                    background-color: transparent;
                    padding: 16px;
                    margin: 0;
                    word-wrap: break-word;
                }
                img {
                    max-width: 100%;
                    height: auto;
                    display: block;
                }
                code {
                    background-color: rgba(175, 184, 193, 0.2);
                    padding: 2px 4px;
                    border-radius: 3px;
                    font-family: 'SF Mono', Monaco, Menlo, monospace;
                    font-size: 85%;
                    color: #24292f;
                }
                pre {
                    background-color: #f6f8fa;
                    padding: 16px;
                    border-radius: 6px;
                    overflow-x: auto;
                    border: 1px solid #d0d7de;
                }
                pre code {
                    background-color: transparent;
                    padding: 0;
                }
                a {
                    color: #1F6FEB;
                    text-decoration: none;
                }
                h1, h2, h3, h4, h5, h6 {
                    color: #24292f;
                    margin-top: 24px;
                    margin-bottom: 16px;
                    font-weight: 600;
                }
                blockquote {
                    border-left: 3px solid #1F6FEB;
                    padding-left: 16px;
                    color: #57606a;
                    margin: 0;
                }
                table {
                    border-collapse: collapse;
                    width: 100%;
                }
                table td, table th {
                    border: 1px solid #d0d7de;
                    padding: 6px 13px;
                }
                table th {
                    font-weight: 600;
                    background-color: #f6f8fa;
                }
                p[align="center"], div[align="center"] {
                    text-align: center;
                }

                /* Dark mode support */
                @media (prefers-color-scheme: dark) {
                    body {
                        color: #E6EDF3;
                    }
                    code {
                        background-color: rgba(110, 118, 129, 0.4);
                        color: #E6EDF3;
                    }
                    pre {
                        background-color: #161B22;
                        border: 1px solid #30363D;
                    }
                    h1, h2, h3, h4, h5, h6 {
                        color: #E6EDF3;
                    }
                    blockquote {
                        color: #8B949E;
                    }
                    table td, table th {
                        border: 1px solid #30363D;
                    }
                    table th {
                        background-color: #161B22;
                    }
                }
            </style>
        </head>
        <body>
            <div id="content"></div>
            <script>
                try {
                    marked.setOptions({
                        breaks: true,
                        gfm: true,
                        headerIds: false,
                        mangle: false
                    });
                    const base64Markdown = "\(base64Markdown)";
                    const markdownText = atob(base64Markdown);
                    document.getElementById('content').innerHTML = marked.parse(markdownText);
                } catch (error) {
                    document.getElementById('content').innerText = 'Error rendering markdown: ' + error.message;
                }
            </script>
        </body>
        </html>
        """
        
        webView.loadHTMLString(html, baseURL: nil)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: MarkdownWebView
        
        init(_ parent: MarkdownWebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if let url = navigationAction.request.url {
                // Allow initial page load
                if url.scheme == "about" || navigationAction.navigationType == .other {
                    decisionHandler(.allow)
                    return
                }
                
                // Handle link clicks - open in Safari
                if navigationAction.navigationType == .linkActivated {
                    // Open in Safari (in-app browser)
                    DispatchQueue.main.async {
                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                           let window = windowScene.windows.first {
                            var topController = window.rootViewController
                            while let presented = topController?.presentedViewController {
                                topController = presented
                            }
                            
                            let safariVC = SFSafariViewController(url: url)
                            topController?.present(safariVC, animated: true)
                        }
                    }
                    decisionHandler(.cancel)
                    return
                }
            }
            
            decisionHandler(.allow)
        }
    }
}
