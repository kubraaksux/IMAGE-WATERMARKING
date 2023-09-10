% Load the source image
original_image = imread('ula.jpg');
original_image = double(original_image) / 255; % Normalize the image to [0,1]
figure, imshow(original_image); % Show the source image
title('Original Image');

% Create a binary mask
a = zeros(size(original_image,1),size(original_image,2));
a(100:250, 100:350) = 1; % Area where the watermark will be applied
figure, imshow(a); % Show the mask
title('Binary Mask');

% Load the watermark image
watermark = imread('albenia.jpg');
watermark = double(watermark) / 255; % Normalize the watermark to [0,1]
figure, imshow(watermark); % Show the watermark
title('Watermark Image');

% Check if watermark is grayscale
if size(watermark, 3) == 1
    % If so, convert the image to grayscale
    original_image = rgb2gray(original_image);
    % Then display the grayscale image
    figure, imshow(original_image);
    title('Grayscale Image');
end

% Resizing the watermark to match the mask size
watermark_resized = imresize(watermark, [size(a,1), size(a,2)]);

% Split the image and the watermark into color channels
x1 = original_image(:,:,1); x2 = original_image(:,:,2); x3 = original_image(:,:,3);
watermark_red = watermark_resized(:, :, 1);
watermark_green = watermark_resized(:, :, 2);
watermark_blue = watermark_resized(:, :, 3);

% Apply the DCT to the image channels
dx1 = dct2(x1); dx2 = dct2(x2); dx3 = dct2(x3);

% Coefficient of watermark strength
g = 0.5; % Chose this value after trial and error

% Apply the watermark and the IDCT
dx1(logical(a)) = dx1(logical(a)) + g * watermark_red(logical(a));
dx2(logical(a)) = dx2(logical(a)) + g * watermark_green(logical(a));
dx3(logical(a)) = dx3(logical(a)) + g * watermark_blue(logical(a));
y1 = idct2(dx1); y2 = idct2(dx2); y3 = idct2(dx3);

% Combine the channels back into an image
y = cat(3, y1, y2, y3);
y = min(max(y, 0), 1); % Clipping to [0,1]

% Create the watermarked image
watermarked_image_to_show = original_image;
watermarked_image_to_show(logical(a)) = watermark_resized(logical(a));

% Show the watermarked image with disabling the watermark
figure;
imshow(watermarked_image_to_show);
title('Watermarked Image with Albenia.jpg');


% Extract the watermark
extracted_watermark_red = (y1 - x1) / g;
extracted_watermark_green = (y2 - x2) / g;
extracted_watermark_blue = (y3 - x3) / g;

% Reshape the extracted watermark back into 2D form
extracted_watermark_red_resized = imresize(extracted_watermark_red, size(watermark_red));
extracted_watermark_green_resized = imresize(extracted_watermark_green, size(watermark_green));
extracted_watermark_blue_resized = imresize(extracted_watermark_blue, size(watermark_blue));

% Combine the color channels into an image
extracted_watermark_resized = cat(3, extracted_watermark_red_resized, extracted_watermark_green_resized, extracted_watermark_blue_resized);

% Show the extracted watermark
figure, imshow(extracted_watermark_resized);
title('Extracted Watermark');
colorbar;

% Compare the extracted watermark to the original watermark
difference = abs(extracted_watermark_resized - watermark);
figure, imshow(difference, []);
title('Difference between Original and Extracted Watermark');
colormap('hot');
colorbar;

% Calculate the RMSE values for each color channel
rmse_red = sqrt(mean((extracted_watermark_red_resized - watermark_red).^2, 'all'));
rmse_green = sqrt(mean((extracted_watermark_green_resized - watermark_green).^2, 'all'));
rmse_blue = sqrt(mean((extracted_watermark_blue_resized - watermark_blue).^2, 'all'));

% Calculate the total RMSE
rmse_total = sqrt(mean((extracted_watermark_resized - watermark_resized).^2, 'all'));

% Display the RMSE values
disp(['RMSE (Red): ' num2str(rmse_red)]);
disp(['RMSE (Green): ' num2str(rmse_green)]);
disp(['RMSE (Blue): ' num2str(rmse_blue)]);
disp(['Total RMSE: ' num2str(rmse_total)]);

% Plot the RMSE values
channels = {'Red', 'Green', 'Blue', 'Total'};
rmse_values = [rmse_red, rmse_green, rmse_blue, rmse_total];
figure;
bar(rmse_values);
xticks(1:4);
xticklabels(channels);
ylabel('RMSE');
title('RMSE Values for Watermark Extraction');
