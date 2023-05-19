/* ------------------  下拉菜单延迟消失，避免鼠标滑不进  ------------------------------  */
function dropdown_delay_disappear(event) {
    //  全局下拉菜单统一处理，只需要html运行一次
    // const dropdowns = document.querySelectorAll('.header-menu');
    // dropdowns.forEach((dropdown) => {
    //     const dropdownTimeoutIds = {};
    //     // 鼠标进入下拉菜单时，也属于进入其父项，需要清除自动消失
    //     dropdown.addEventListener('mouseenter', () => {
    //         clearTimeout(dropdownTimeoutIds.mouseleave);
    //         try{
    //         dropdown.querySelector('ul').style.display = 'block';
    //         }catch(ex){}
    //     }, { once: true });

    //     dropdown.addEventListener('mouseleave', () => {
    //         dropdownTimeoutIds.mouseleave = setTimeout(() => {
    //             try{
    //             dropdown.querySelector('ul').style.display = 'none';
    //             }catch(ex){}
    //             clearTimeout(dropdownTimeoutIds.mouseleave);  // 定时器执行完后，自行销毁
    //         }, 100);
    //     }, { once: true });
    // })

    //  每个导航栏菜单单独运行，只针对自己的下拉菜单 
    var parentElement =event.target.parentNode ; // = document.currentScript.parentElement;
    var dropdowns = parentElement.querySelectorAll("ul");  // 不用querySelector()是考虑到会有多个之类
    var timer;

    function set_all(params) {
        dropdowns.forEach((dropdown)=>{dropdown.style.display = params;});
    }

    const fn1 = function (){
        clearTimeout(timer);
        try{
        set_all("block");
        }catch(ex){}
    }
    parentElement.removeEventListener('mouseenter',fn1);  // 避免重复监听事件，消耗资源
    parentElement.addEventListener('mouseenter',fn1, { once: true });
    const fn2 = function (){
        timer = setTimeout(() => {
            try{
            set_all("none");
            }catch(ex){}
            clearTimeout(timer);  // 定时器执行完后，自行销毁
        }, 130);
    }
    parentElement.removeEventListener('mouseleave',fn2)
    parentElement.addEventListener('mouseleave', fn2, { once: true });

}

// confirm('This is a win!');
// console.log('console');
/* ------------------  轮播函数  ------------------------------  */
function slideshow_imgs(timeout =1000) {
    var current_index=0;
    // 只针对当前的容器，不会读取到其他容器
    const parentElement = document.currentScript.parentElement;
    const bt_prev = parentElement.querySelector(".prev");
    const bt_next = parentElement.querySelector(".next");
    // var slideshows_div = parentElement.querySelector(".slideshow");
    const slideshows = parentElement.querySelector(".slideshow").querySelectorAll(".slideshow-image");
    var timer;

    //  添加：轮播下方的索引图标
    const sliderDotsContainer = parentElement.querySelector('.slider-dots'); // 获取索引小图标的容器元素
    // 根据轮播项的数量生成索引小图标
    for (let i = 0; i < slideshows.length; i++) {
        const dot = document.createElement('span');
        dot.classList.add('dot'); // 添加类名 dot
        sliderDotsContainer.appendChild(dot); // 将图标添加到容器元素中
    }
    const dots = sliderDotsContainer.querySelectorAll('.dot'); // 获取所有索引小图标
    // 设置活动索引小图标
    function setActiveDot(index) {
        // // 移除所有索引小图标的 active 类名
        dots.forEach((dot) => dot.classList.remove('active'));
        // // 添加 active 类名到当前索引小图标
        dots[index].classList.add('active');
    }
      
    // 节能保护：只有一个图，不开启轮播
    if(slideshows.length<=1){
        //  翻页按钮不显示
        bt_prev.style.display="none";
        bt_next.style.display="none";
        return;  // 结束
    }

    //  切换效果：左右切换
    function showImage(idx, last_idx) {
        setActiveDot(idx);
        //  连续循环拼接效果
        function img_priority(idx) {
            for (var i=0; i<slideshows.length; i++){
                slideshows[i].style.zIndex = "0"; 
            }
            if (idx>last_idx){  // 向右
                slideshows[idx].style.zIndex = "3";  
                slideshows[(idx+1)%slideshows.length].style.zIndex = "1"; 
                idx2 = idx-1; 
                if (idx2 <0){ idx2 = slideshows.length-1; }
                slideshows[idx2].style.zIndex = "2";  
            }else{  //向左
                slideshows[idx].style.zIndex = "3";  
                slideshows[(idx+1)%slideshows.length].style.zIndex = "2"; 
                idx2 = idx-1; 
                if (idx2 <0){ idx2 = slideshows.length-1; }
                slideshows[idx2].style.zIndex = "1";  
            }
            
        }
        img_priority(idx);  //  连续循环拼接效果
        // console.log(idx, ':', slideshows[0].style.zIndex, slideshows[1].style.zIndex, slideshows[2].style.zIndex)
        for (var i=0; i<slideshows.length; i++){
            var position = i;

            if (idx==(slideshows.length-1) && i==0){   position=slideshows.length;  }  //  显示最后一张时，第一页切换上来
            if (idx==0 && i==(slideshows.length-1)){  position=-1;  }  //  显示第一张时，最后一页切换在左边
            slideshows[i].style.transform = `translateX(${(position-idx) * 100}%)`;  // 图片移出效果  注意，这个不是引号
        }
        current_index = idx;
    }

    //切换效果：突显
    function showImage2(idx, last_idx) {
        setActiveDot(idx);
        // var slideshows = parentElement.querySelector(".slideshow").querySelectorAll(".slideshow-image")
        for (var i=0; i<slideshows.length; i++){
            slideshows[i].style.display='none'; 
        }
        slideshows[idx].style.display='block';
        slideshows[idx].style.transform = `translateX(-${idx * 10}%)`;  // 图片移出效果  注意，这个不是引号
        current_index = idx;
    }

    function auto_nextImage() {
        current_index++;
        if(current_index>=slideshows.length){ current_index=0;}
        showImage(current_index, current_index-1);
    }

    // 上一张按钮点击事件处理函数
    function prevImage() {
        current_index--;
        // var slideshows = parentElement.querySelector(".slideshow").querySelectorAll(".slideshow-image")
        if (current_index < 0) { current_index = slideshows.length - 1; }
        showImage(current_index, current_index+1);
    }

    // 下一张按钮点击事件处理函数
    function nextImage() {
        current_index++;
        if (current_index >= slideshows.length) { current_index = 0; }
        showImage(current_index, current_index-1);
    }

    // 开始自动播放
    function startSlideshow() {
        timer = setInterval(auto_nextImage, timeout);
    }

    // 停止自动播放
    function stopSlideshow() {
        clearInterval(timer);
    }

    // 绑定按钮点击事件
    bt_prev.removeEventListener('click', prevImage);
    bt_prev.addEventListener('click', prevImage, { once: true });
    bt_next.removeEventListener('click', nextImage);
    bt_next.addEventListener('click', nextImage, { once: true });

    bt_prev.removeEventListener('mouseenter', stopSlideshow);
    bt_prev.addEventListener('mouseenter', stopSlideshow, { once: true });
    bt_next.removeEventListener('mouseenter', stopSlideshow);
    bt_next.addEventListener('mouseenter', stopSlideshow, { once: true });

    // 鼠标悬停时停止自动播放，移出时恢复自动播放
    var slidewin = parentElement.querySelector(".slideshow");
    //  onmouseover：当鼠标指针移动到元素上方时触发该事件。移动到子元素时也触发  //  mouseenter:鼠标在子节点上不会触发
    slidewin.removeEventListener('mouseenter', stopSlideshow); 
    slidewin.addEventListener('mouseenter', stopSlideshow, { once: true });  
    slidewin.removeEventListener('mouseleave', startSlideshow);
    slidewin.addEventListener('mouseleave', startSlideshow, { once: true });

    
    // 为每个索引小图标添加点击事件监听器
    dots.forEach((dot, index) => {
        const fn3 = () => {
            showImage(index, current_index); // 切换到对应索引的轮播项
        }
        dot.removeEventListener('click', fn3);
        dot.addEventListener('click', fn3, { once: true });
        dot.removeEventListener('mouseenter', fn3);
        dot.addEventListener('mouseenter', fn3, { once: true });
        dot.removeEventListener('mouseleave', fn3);
        dot.addEventListener('mouseleave', fn3, { once: true });
    });


    showImage(0);
    //设置定时器，每隔两秒切换一张图片
    startSlideshow();
    // console.log(index);
}

/*  前情知识
    clientWidth: 文档根元素（即 <html> 元素）的可见宽度，不包括滚动条的宽度。它表示了视口（Viewport）的宽度，即浏览器窗口内部的可见区域宽度。
    innerWidth: 表示浏览器窗口的视口宽度，即可见区域的宽度，不包括垂直滚动条的宽度（如果有的话）。
    offsetWidth: 表示文档根元素的完整宽度，包括滚动条的宽度。
*/
/* ------------------  页面嵌入 发送信息 ------------------------------  */
function co_domain_message_send() {
    // 发送消息给父文档
    var iframeHeight = document.documentElement.scrollHeight;
    var iframeWidth = document.documentElement.scrollWidth;
    var data = { iframeHeight: iframeHeight, iframeWidth:iframeWidth }
    parent.postMessage(data, '*');
    console.log("send iframe data", data);
}

/* ------------------  页面嵌入 接收信息 ------------------------------  */
function messaage_resize_iframe_recv(event) {
        const id_name = 'my_frame';
        // 判断消息来源是否为你的目标 iframe
        if (event.source === document.getElementById(id_name).contentWindow) {
            // 接收消息并执行相应操作
            var data = event.data; // 接收到的数据
            var iframeHeight = Math.ceil(data.iframeHeight*1.0); // 从数据中获取 iframe 的高度
            // 根据 iframe 的高度调整父元素的高度
            document.getElementById(id_name).style.height = iframeHeight + 'px';
            
            var iframeWidth = Math.ceil(data.iframeWidth*1.0); // 从数据中获取 iframe 的宽度
            document.getElementById(id_name).style.width =  iframeWidth + 'px';
            // console.log("index recv iframe data:", data,);
            // console.log("\t",  'iframeH:', iframeHeight, 'W:', iframeWidth)
        }
        // console.log("\n\tsource:", event.source, "\n\torigin:", event.origin, "\n\tdata:", event.data);
    }
function auto_resize_iframe_recv(event) {
    // 监听跨文档消息
    window.removeEventListener('message', messaage_resize_iframe_recv);
    window.addEventListener('message', messaage_resize_iframe_recv, ); //, { once: true }
    // console.log("set massage listen for iframe resize!");
}





// 监听窗口大小变化
function get_win_size(params) {
    function win_resize2() {
        const iframe = document.querySelector('iframe');
        //  document.documentElement
        // 在窗口大小改变时重新布局元素
        var clientWidth = iframe.clientWidth;
        var clientHeight = iframe.clientHeight;
        //  window
        var innerWidth = iframe.innerWidth;
        var innerHeight = iframe.innerHeight;;
        
        var offsetWidth = iframe.offsetWidth;
        var offsetHeight = iframe.offsetHeight;

        console.log('index', 'client h W:', clientHeight, clientWidth)
        console.log('\tindex', 'inner h W:', innerHeight, innerWidth)
        console.log('\t\tindex', 'iframe h W:', offsetHeight, offsetWidth)
    }
    window.removeEventListener('resize', win_resize2, );
    window.addEventListener('resize', win_resize2, );
}
