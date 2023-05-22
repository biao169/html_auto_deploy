//  将布局中每一行的图像隐藏 
function disappear_images(ele){
    let imgs = document.querySelectorAll(".div-image");
    let button = ele ;
    if (imgs[0].style.display=="none"){
        imgs.forEach((img)=>{ img.style.display='flex';});
        // button.textContent = "Hidden Picture";
        button.querySelector('span').style.color = 'yellow';
    }
    else{
        imgs.forEach((img)=>{ img.style.display='none';});
        // button.textContent = "Show Picture";
        button.querySelector('span').style.color = 'mediumseagreen';
    }
    // console.log('====', imgs[0].style.display, ele.textContent);
}

/*  将每一行统一高度  */
function auto_format_row_height(){
    const containers = document.querySelectorAll(".div-paper-container");
    // var max_img_height = 0;
    // var max_img_width = 0;
    
    function justment(papers){
        papers.forEach((paper, index)=>{
            let div_img = paper.querySelector('.div-image');
            let img = div_img.querySelector('.image');
            // 获取计算后的样式
            const computedStyle = window.getComputedStyle(div_img);
            let minWidth = computedStyle.minWidth;
            const maxWidth = computedStyle.maxWidth;
            if (minWidth <40 || minWidth=="auto") {  minWidth = 40;  }

            let max_img_height = paper.offsetHeight;
            let max_img_width = paper.offsetWidth;
            console.log(index, 'paper heighth:', max_img_height, 'widt:', max_img_width,);
            max_img_width = Math.ceil(max_img_width*0.1);
            if (max_img_width>maxWidth){ max_img_width=maxWidth; }
            if (max_img_width<minWidth){ max_img_width=minWidth; }
            max_img_height = max_img_width;

            div_img.style.height  = max_img_height+'px';
            div_img.style.width = max_img_width+'px';
            // img.style.height  = (max_img_height-20)+'px';
            // img.style.width = (max_img_width-20)+'px';
            // img.offsetWidth = img.offsetHeight;
            // console.log(index, "new H W:", div_img.offsetHeight, div_img.offsetWidth, ':', max_img_height, max_img_width)
            // console.log('width:', div_img.clientWidth, 'height:', img.clientHeight, img.offsetHeight)
        });
        
        

    }
    containers.forEach((container, index)=>{ 
        let papers = container.querySelectorAll('.div-one-paper');
        justment(papers); 
    });
}




/*  前情知识
    clientWidth: 文档根元素（即 <html> 元素）的可见宽度，不包括滚动条的宽度。它表示了视口（Viewport）的宽度，即浏览器窗口内部的可见区域宽度。
    innerWidth: 表示浏览器窗口的视口宽度，即可见区域的宽度，不包括垂直滚动条的宽度（如果有的话）。
    offsetWidth: 表示文档根元素的完整宽度，包括滚动条的宽度。
    scrollHeight: 表示整个文档的高度，包括滚动内容的高度和被隐藏的部分，不包括滚动条的高度。
*/
function co_domain_message_send() {
    // 发送消息给父文档
    // scrollHeight: 表示整个文档的高度，包括滚动内容的高度和被隐藏的部分，不包括滚动条的高度。
    // var iframeHeight = document.documentElement.scrollHeight;
    // var iframeWidth = document.documentElement.scrollWidth;
    //  选用真实宽高
    var offsetWidth = document.documentElement.offsetWidth; 
    var offsetHeight = document.documentElement.offsetHeight+10;

    // var data = { iframeHeight: iframeHeight, iframeWidth:iframeWidth }
    // var data = { iframeHeight: Math.max(iframeHeight, window.innerHeight, document.documentElement.offsetHeight),
    //              iframeWidth:Math.max(iframeWidth, window.innerWidth, document.documentElement.offsetWidth) }
    var data = { iframeHeight: offsetHeight, iframeWidth:offsetWidth }
    parent.postMessage(data, '*');
    // console.log("send iframe data", data, 'win height:', window.innerHeight, 'win width:', window.innerWidth);
}


//  主界面 iframe 尺寸更新时，子界面也会自动更新尺寸，但需要把新尺寸发送给主界面，以更新iframe场次 
function auto_resize_iframe_send(){
    // 监听主界面传递的尺寸信息
    co_domain_message_send();
    window.removeEventListener('resize', co_domain_message_send, );
    window.addEventListener('resize', co_domain_message_send, );

    window.removeEventListener('resize', auto_format_row_height, );
    window.addEventListener('resize', auto_format_row_height, );
    // console.log("set auto send iframe data!");
}

function get_win_size() {
    var num = 0;
    function win_resize2() {
        // 在窗口大小改变时重新布局元素
        // clientWidth: 文档根元素（即 <html> 元素）的可见宽度，不包括滚动条的宽度。它表示了视口（Viewport）的宽度，即浏览器窗口内部的可见区域宽度。
        var clientWidth = document.documentElement.clientWidth;  // 
        var clientHeight = document.documentElement.clientHeight;
        //  innerWidth: 表示浏览器窗口的视口宽度，即可见区域的宽度，不包括垂直滚动条的宽度（如果有的话）。
        //  innerHeight: 表示浏览器窗口的视口高度，即可见区域的高度，不包括水平滚动条的高度（如果有的话）。
        var innerWidth = window.innerWidth;
        var innerHeight = window.innerHeight;
        //  offsetWidth: 表示文档根元素的完整宽度，包括滚动条的宽度。
        var offsetWidth = document.documentElement.offsetWidth;  // 
        var offsetHeight = document.documentElement.offsetHeight;

        var scrolHeight = document.documentElement.scrollHeight;
        var scrolWidth = document.documentElement.scrollWidth;

        console.log('paper', 'client h W:', clientHeight, clientWidth)
        console.log('\tpaper', 'inner h W:', innerHeight, innerWidth)
        console.log('\tpaper', 'scrol h W:', scrolHeight, scrolWidth)
        console.log('\t\tpaper', 'offset h W:', offsetHeight, offsetWidth, num)
    }
    window.removeEventListener('resize', win_resize2, );
    window.addEventListener('resize', win_resize2, );
    // console.log('end');
}

