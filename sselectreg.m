function sselectreg(filename)
%SSELECTREG Subselects cells within a user-defined region
%   SSELECTREG(FILENAME) uses a Matlab figure FILENAME with previously
%   detected cells to draw a region of interest and count cells within it.
%   The region of interest is a polygon defined using mouse clicks. To
%   finish the polygon, click outside the plot box.
%
%   Input-output specs
%   ==================
%   FILENAME	- string (like: 'your_figure_name.fig')
%
%   Author
%   ======
%   Sergey Shuvaev, 2019. sshuvaev@cshl.edu

    fig = openfig(filename);
    axObjs = fig.Children;
    dataObjs = axObjs.Children;

    xsize = dataObjs(2).XData(2);
    ysize = dataObjs(2).YData(2);

    x = dataObjs(1).XData;
    y = dataObjs(1).YData;

    xlist = [];
    ylist = [];

    while(true)

        %Save the mouse-selected coordinates

        [ysel, xsel] = ginput(1);
        xsel = round(xsel);
        ysel = round(ysel);

        %Click outside the image stops the interaction

        if(xsel < 1 || ysel < 1 || xsel > ysize || ysel > xsize)
            break
        end

        xlist = [xlist, xsel];
        ylist = [ylist, ysel];

        if length(xlist) > 1
            line([ylist(end), ylist(end - 1)], [xlist(end), xlist(end - 1)], 'color', 'w')
            drawnow
        else
            hold on
            plot(ysel, xsel, 'wo')
            drawnow
        end
    end
    line([ylist(end), ylist(1)], [xlist(end), xlist(1)], 'color', 'w')
    
    mask = poly2mask(ylist, xlist, ysize, xsize);
    ix = find(mask(sub2ind([ysize, xsize], y, x))==1);
    plot(x(ix), y(ix), 'wo')
    title(sprintf('Number of selected spots: %d', length(ix)))

end
