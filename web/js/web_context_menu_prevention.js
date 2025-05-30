// 禁用Web浏览器的默认右键菜单
(function() {
    'use strict';
    
    // 禁用右键菜单
    document.addEventListener('contextmenu', function(e) {
        e.preventDefault();
        return false;
    }, { passive: false });
    
    // 禁用选择文本（可选）
    document.addEventListener('selectstart', function(e) {
        // 只在特定情况下禁用文本选择
        if (e.target.closest('.flutter-view') || e.target.closest('flt-glass-pane')) {
            e.preventDefault();
            return false;
        }
    }, { passive: false });
    
    // 禁用拖拽（可选）
    document.addEventListener('dragstart', function(e) {
        if (e.target.closest('.flutter-view') || e.target.closest('flt-glass-pane')) {
            e.preventDefault();
            return false;
        }
    }, { passive: false });
    
    // 监听Flutter应用加载完成
    document.addEventListener('DOMContentLoaded', function() {
        console.log('Web context menu prevention loaded');
    });
})();
