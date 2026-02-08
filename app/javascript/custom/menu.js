//  RailsのTurboという仕組みを高速化のために使用している。ページを完全に作り直さず、中身だけを入れ替える
// 完全にページを読み込むようにするには"DOMContentLoaded"を使用
document.addEventListener("turbo:load", function () {

    // id=accountを探してデータを代入
    let account = document.querySelector("#account");
    if (account) {

        // id=accountがクリックされた際にfunction作動
        account.addEventListener("click", function (event) {

            // リンクをクリックした際の本来の動きをキャンセル
            event.preventDefault();

            // id=dropdown-menuを探してデータを代入
            let menu = document.querySelector("#dropdown-menu");

            // activeクラスがある場合外して無い場合は付ける（これによってドロップダウンメニューを付けたり外したりできる）
            menu.classList.toggle("active");
        });
    }
});